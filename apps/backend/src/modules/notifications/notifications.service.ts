import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';
import { ParcelStatus } from '@prisma/client';

import { PrismaService } from '../../prisma/prisma.service';

export interface NotificationPayload {
  title: string;
  body: string;
  data?: Record<string, string>;
}

@Injectable()
export class NotificationsService implements OnModuleInit {
  private readonly logger = new Logger(NotificationsService.name);
  private firebaseInitialized = false;

  constructor(
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
  ) {}

  onModuleInit() {
    this.initializeFirebase();
  }

  private initializeFirebase() {
    const serviceAccountJson = this.configService.get<string>('FIREBASE_SERVICE_ACCOUNT');

    if (!serviceAccountJson) {
      this.logger.warn('FIREBASE_SERVICE_ACCOUNT not configured. Push notifications disabled.');
      return;
    }

    try {
      const serviceAccount = JSON.parse(serviceAccountJson);

      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });

      this.firebaseInitialized = true;
      this.logger.log('Firebase Admin SDK initialized successfully');
    } catch (error) {
      this.logger.error('Failed to initialize Firebase Admin SDK:', error);
    }
  }

  async sendToUser(userId: string, payload: NotificationPayload): Promise<boolean> {
    if (!this.firebaseInitialized) {
      this.logger.debug('Firebase not initialized, skipping notification');
      return false;
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { pushToken: true, notificationsEnabled: true },
    });

    if (!user || !user.pushToken || !user.notificationsEnabled) {
      this.logger.debug(`User ${userId} does not have push notifications enabled`);
      return false;
    }

    return this.sendToToken(user.pushToken, payload);
  }

  async sendToToken(token: string, payload: NotificationPayload): Promise<boolean> {
    if (!this.firebaseInitialized) {
      return false;
    }

    try {
      const message: admin.messaging.Message = {
        token,
        notification: {
          title: payload.title,
          body: payload.body,
        },
        data: payload.data,
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      const response = await admin.messaging().send(message);
      this.logger.debug(`Push notification sent: ${response}`);
      return true;
    } catch (error: any) {
      if (error.code === 'messaging/registration-token-not-registered') {
        // Token is invalid, remove it from the database
        await this.prisma.user.updateMany({
          where: { pushToken: token },
          data: { pushToken: null },
        });
        this.logger.debug(`Removed invalid push token`);
      } else {
        this.logger.error('Failed to send push notification:', error);
      }
      return false;
    }
  }

  async sendParcelStatusNotification(
    userId: string,
    parcelId: string,
    parcelTitle: string,
    oldStatus: ParcelStatus,
    newStatus: ParcelStatus,
  ): Promise<void> {
    const statusMessages: Record<ParcelStatus, string> = {
      PENDING: 'is waiting for pickup',
      INFO_RECEIVED: 'information has been received',
      IN_TRANSIT: 'is now in transit',
      OUT_FOR_DELIVERY: 'is out for delivery today',
      DELIVERED: 'has been delivered',
      FAILED_ATTEMPT: 'delivery attempt failed',
      EXCEPTION: 'has an exception - please check',
      EXPIRED: 'tracking has expired',
      UNKNOWN: 'status updated',
    };

    const title = this.getNotificationTitle(newStatus);
    const body = `${parcelTitle} ${statusMessages[newStatus]}`;

    await this.sendToUser(userId, {
      title,
      body,
      data: {
        type: 'parcel_status_change',
        parcelId,
        oldStatus,
        newStatus,
      },
    });
  }

  private getNotificationTitle(status: ParcelStatus): string {
    switch (status) {
      case 'DELIVERED':
        return 'Package Delivered!';
      case 'OUT_FOR_DELIVERY':
        return 'Out for Delivery';
      case 'FAILED_ATTEMPT':
      case 'EXCEPTION':
        return 'Action Required';
      default:
        return 'Tracking Update';
    }
  }

  async sendNewTrackingEventNotification(
    userId: string,
    parcelId: string,
    parcelTitle: string,
    eventDescription: string,
    location?: string,
  ): Promise<void> {
    let body = eventDescription;
    if (location) {
      body += ` (${location})`;
    }

    await this.sendToUser(userId, {
      title: `Update: ${parcelTitle}`,
      body,
      data: {
        type: 'tracking_event',
        parcelId,
      },
    });
  }

  async registerPushToken(userId: string, token: string): Promise<void> {
    await this.prisma.user.update({
      where: { id: userId },
      data: { pushToken: token },
    });
    this.logger.debug(`Registered push token for user ${userId}`);
  }

  async unregisterPushToken(userId: string): Promise<void> {
    await this.prisma.user.update({
      where: { id: userId },
      data: { pushToken: null },
    });
    this.logger.debug(`Unregistered push token for user ${userId}`);
  }

  async updateNotificationPreferences(
    userId: string,
    enabled: boolean,
  ): Promise<void> {
    await this.prisma.user.update({
      where: { id: userId },
      data: { notificationsEnabled: enabled },
    });
  }
}
