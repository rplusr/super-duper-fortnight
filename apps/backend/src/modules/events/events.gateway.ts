import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Logger, UseGuards } from '@nestjs/common';
import { Server, Socket } from 'socket.io';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';

interface AuthenticatedSocket extends Socket {
  userId?: string;
}

@WebSocketGateway({
  cors: {
    origin: '*',
    credentials: true,
  },
  namespace: '/events',
})
export class EventsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(EventsGateway.name);
  private userSockets: Map<string, Set<string>> = new Map();

  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async handleConnection(client: AuthenticatedSocket) {
    try {
      const token = this.extractToken(client);
      if (!token) {
        this.logger.warn(`Client ${client.id} disconnected: No token provided`);
        client.disconnect();
        return;
      }

      const payload = this.jwtService.verify(token, {
        secret: this.configService.get<string>('JWT_SECRET'),
      });

      client.userId = payload.sub;

      // Track user's socket connections
      if (!this.userSockets.has(client.userId)) {
        this.userSockets.set(client.userId, new Set());
      }
      this.userSockets.get(client.userId)!.add(client.id);

      // Join user-specific room
      client.join(`user:${client.userId}`);

      this.logger.log(`Client ${client.id} connected for user ${client.userId}`);

      client.emit('connected', { message: 'Connected to real-time updates' });
    } catch (error) {
      this.logger.error(`Authentication failed for client ${client.id}:`, error);
      client.disconnect();
    }
  }

  handleDisconnect(client: AuthenticatedSocket) {
    if (client.userId) {
      const userSocketSet = this.userSockets.get(client.userId);
      if (userSocketSet) {
        userSocketSet.delete(client.id);
        if (userSocketSet.size === 0) {
          this.userSockets.delete(client.userId);
        }
      }
    }
    this.logger.log(`Client ${client.id} disconnected`);
  }

  private extractToken(client: Socket): string | null {
    const authHeader = client.handshake.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      return authHeader.substring(7);
    }

    const token = client.handshake.auth?.token;
    if (token) {
      return token;
    }

    return client.handshake.query?.token as string || null;
  }

  @SubscribeMessage('subscribe:parcel')
  handleSubscribeParcel(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() data: { parcelId: string },
  ) {
    if (!client.userId) {
      return { error: 'Not authenticated' };
    }

    client.join(`parcel:${data.parcelId}`);
    this.logger.debug(`User ${client.userId} subscribed to parcel ${data.parcelId}`);

    return { subscribed: true, parcelId: data.parcelId };
  }

  @SubscribeMessage('unsubscribe:parcel')
  handleUnsubscribeParcel(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() data: { parcelId: string },
  ) {
    client.leave(`parcel:${data.parcelId}`);
    this.logger.debug(`User ${client.userId} unsubscribed from parcel ${data.parcelId}`);

    return { unsubscribed: true, parcelId: data.parcelId };
  }

  // Methods to emit events from other services
  emitParcelUpdate(userId: string, parcelId: string, data: any) {
    this.server.to(`user:${userId}`).emit('parcel:updated', {
      parcelId,
      ...data,
    });
    this.server.to(`parcel:${parcelId}`).emit('parcel:updated', {
      parcelId,
      ...data,
    });
    this.logger.debug(`Emitted parcel update for ${parcelId} to user ${userId}`);
  }

  emitNewTrackingEvent(userId: string, parcelId: string, event: any) {
    this.server.to(`user:${userId}`).emit('tracking:new-event', {
      parcelId,
      event,
    });
    this.server.to(`parcel:${parcelId}`).emit('tracking:new-event', {
      parcelId,
      event,
    });
    this.logger.debug(`Emitted new tracking event for ${parcelId}`);
  }

  emitStatusChange(userId: string, parcelId: string, oldStatus: string, newStatus: string) {
    this.server.to(`user:${userId}`).emit('parcel:status-changed', {
      parcelId,
      oldStatus,
      newStatus,
      timestamp: new Date().toISOString(),
    });
    this.logger.debug(`Emitted status change for ${parcelId}: ${oldStatus} -> ${newStatus}`);
  }

  isUserOnline(userId: string): boolean {
    return this.userSockets.has(userId) && this.userSockets.get(userId)!.size > 0;
  }
}
