import {
  Controller,
  Post,
  Body,
  Headers,
  HttpCode,
  HttpStatus,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiHeader } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';

import { PrismaService } from '../../prisma/prisma.service';
import { TrackingService } from './tracking.service';
import { Public } from '../../common/decorators/public.decorator';

interface AftershipWebhookPayload {
  event: string;
  msg: {
    id: string;
    tracking_number: string;
    slug: string;
    tag: string;
    subtag: string;
    checkpoints: Array<{
      checkpoint_time: string;
      city: string;
      country_name: string;
      location: string;
      message: string;
      tag: string;
      subtag: string;
    }>;
  };
}

@ApiTags('Webhooks')
@Controller('webhooks')
export class TrackingController {
  private readonly logger = new Logger(TrackingController.name);

  constructor(
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
    private readonly trackingService: TrackingService,
  ) {}

  @Post('aftership')
  @Public()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Receive tracking updates from AfterShip' })
  @ApiHeader({
    name: 'aftership-hmac-sha256',
    description: 'HMAC signature for webhook verification',
  })
  @ApiResponse({ status: 200, description: 'Webhook processed successfully' })
  @ApiResponse({ status: 401, description: 'Invalid webhook signature' })
  async handleAftershipWebhook(
    @Body() payload: AftershipWebhookPayload,
    @Headers('aftership-hmac-sha256') signature: string,
    @Body() rawBody: any,
  ) {
    // Verify webhook signature
    const webhookSecret = this.configService.get<string>('AFTERSHIP_WEBHOOK_SECRET');
    if (webhookSecret) {
      const expectedSignature = crypto
        .createHmac('sha256', webhookSecret)
        .update(JSON.stringify(rawBody))
        .digest('base64');

      if (signature !== expectedSignature) {
        this.logger.warn('Invalid AfterShip webhook signature');
        throw new UnauthorizedException('Invalid webhook signature');
      }
    }

    this.logger.log(
      `Received AfterShip webhook: ${payload.event} for ${payload.msg.tracking_number}`,
    );

    // Find parcel by tracking number
    const parcels = await this.prisma.parcel.findMany({
      where: {
        trackingNumber: payload.msg.tracking_number,
      },
    });

    if (parcels.length === 0) {
      this.logger.warn(
        `Received webhook for unknown tracking number: ${payload.msg.tracking_number}`,
      );
      return { status: 'ignored', reason: 'tracking_number_not_found' };
    }

    // Update each parcel (could be tracked by multiple users)
    for (const parcel of parcels) {
      try {
        await this.trackingService.syncParcelTracking(parcel.id);
        this.logger.log(`Synced tracking for parcel ${parcel.id}`);
      } catch (error) {
        this.logger.error(`Failed to sync parcel ${parcel.id}:`, error);
      }
    }

    return { status: 'processed', parcelsUpdated: parcels.length };
  }
}
