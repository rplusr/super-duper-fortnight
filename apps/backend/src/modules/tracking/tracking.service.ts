import { Injectable, Logger } from '@nestjs/common';
import { CarrierType, ParcelStatus, Parcel } from '@prisma/client';

import { PrismaService } from '../../prisma/prisma.service';
import { AftershipClient, TrackingInfo, TrackingCheckpoint } from './clients/aftership.client';
import { CarrierDetectionService } from './carrier-detection.service';
import { EventsGateway } from '../events/events.gateway';
import { NotificationsService } from '../notifications/notifications.service';

export interface TrackingResult {
  success: boolean;
  parcel?: Parcel;
  trackingInfo?: TrackingInfo;
  error?: string;
}

@Injectable()
export class TrackingService {
  private readonly logger = new Logger(TrackingService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly aftershipClient: AftershipClient,
    private readonly carrierDetectionService: CarrierDetectionService,
    private readonly eventsGateway: EventsGateway,
    private readonly notificationsService: NotificationsService,
  ) {}

  async trackParcel(
    trackingNumber: string,
    carrier?: CarrierType,
  ): Promise<TrackingInfo | null> {
    // Auto-detect carrier if not provided
    let detectedCarrier = carrier;
    let carrierSlug: string | undefined;

    if (!detectedCarrier) {
      const detection = this.carrierDetectionService.detectCarrier(trackingNumber);
      if (detection) {
        detectedCarrier = detection.carrier;
      }
    }

    if (detectedCarrier) {
      carrierSlug = this.getAftershipSlug(detectedCarrier);
    }

    try {
      const trackingInfo = await this.aftershipClient.getTracking(
        trackingNumber,
        carrierSlug,
      );
      return trackingInfo;
    } catch (error) {
      this.logger.error(`Failed to track parcel ${trackingNumber}:`, error);
      return null;
    }
  }

  async syncParcelTracking(parcelId: string): Promise<TrackingResult> {
    const parcel = await this.prisma.parcel.findUnique({
      where: { id: parcelId },
    });

    if (!parcel) {
      return { success: false, error: 'Parcel not found' };
    }

    const oldStatus = parcel.status;

    try {
      const trackingInfo = await this.trackParcel(
        parcel.trackingNumber,
        parcel.carrier,
      );

      if (!trackingInfo) {
        return { success: false, error: 'Unable to fetch tracking information' };
      }

      const newStatus = this.mapToParcelStatus(trackingInfo.tag);

      // Update parcel status
      const updatedParcel = await this.prisma.parcel.update({
        where: { id: parcelId },
        data: {
          status: newStatus,
          estimatedDelivery: trackingInfo.expectedDelivery
            ? new Date(trackingInfo.expectedDelivery)
            : null,
          originCountry: trackingInfo.originCountryIso3,
          destinationCountry: trackingInfo.destinationCountryIso3,
          lastSyncAt: new Date(),
        },
      });

      // Sync tracking events and get new events count
      let newEventsCount = 0;
      if (trackingInfo.checkpoints && trackingInfo.checkpoints.length > 0) {
        newEventsCount = await this.syncTrackingEvents(parcelId, trackingInfo.checkpoints);
      }

      // Emit WebSocket events and send push notification if status changed
      if (oldStatus !== newStatus) {
        this.eventsGateway.emitStatusChange(
          parcel.userId,
          parcelId,
          oldStatus,
          newStatus,
        );

        // Send push notification for status change
        const parcelTitle = parcel.title || parcel.trackingNumber;
        this.notificationsService
          .sendParcelStatusNotification(
            parcel.userId,
            parcelId,
            parcelTitle,
            oldStatus,
            newStatus,
          )
          .catch((err) => {
            this.logger.error('Failed to send push notification:', err);
          });
      }

      // Emit parcel update event
      this.eventsGateway.emitParcelUpdate(parcel.userId, parcelId, {
        status: newStatus,
        estimatedDelivery: updatedParcel.estimatedDelivery,
        lastSyncAt: updatedParcel.lastSyncAt,
        newEventsCount,
      });

      return {
        success: true,
        parcel: updatedParcel,
        trackingInfo,
      };
    } catch (error) {
      this.logger.error(`Failed to sync tracking for parcel ${parcelId}:`, error);
      return { success: false, error: 'Failed to sync tracking' };
    }
  }

  private async syncTrackingEvents(
    parcelId: string,
    checkpoints: TrackingCheckpoint[],
  ): Promise<number> {
    // Get parcel for userId
    const parcel = await this.prisma.parcel.findUnique({
      where: { id: parcelId },
      select: { userId: true },
    });

    // Get existing events
    const existingEvents = await this.prisma.trackingEvent.findMany({
      where: { parcelId },
      select: { timestamp: true, statusCode: true },
    });

    const existingSet = new Set(
      existingEvents.map((e) => `${e.timestamp.toISOString()}-${e.statusCode}`),
    );

    // Filter new events
    const newEvents = checkpoints.filter((checkpoint) => {
      const key = `${new Date(checkpoint.checkpointTime).toISOString()}-${checkpoint.tag}`;
      return !existingSet.has(key);
    });

    if (newEvents.length > 0) {
      await this.prisma.trackingEvent.createMany({
        data: newEvents.map((checkpoint) => ({
          parcelId,
          status: checkpoint.subtag || checkpoint.tag,
          statusCode: checkpoint.tag,
          description: checkpoint.message,
          location: checkpoint.location,
          city: checkpoint.city,
          country: checkpoint.countryName,
          timestamp: new Date(checkpoint.checkpointTime),
          rawData: checkpoint as object,
        })),
      });

      // Emit new tracking events via WebSocket
      if (parcel) {
        for (const checkpoint of newEvents) {
          this.eventsGateway.emitNewTrackingEvent(parcel.userId, parcelId, {
            status: checkpoint.subtag || checkpoint.tag,
            statusCode: checkpoint.tag,
            description: checkpoint.message,
            location: checkpoint.location,
            city: checkpoint.city,
            country: checkpoint.countryName,
            timestamp: checkpoint.checkpointTime,
          });
        }
      }
    }

    return newEvents.length;
  }

  private mapToParcelStatus(tag: string): ParcelStatus {
    const statusMap: Record<string, ParcelStatus> = {
      Pending: ParcelStatus.PENDING,
      InfoReceived: ParcelStatus.INFO_RECEIVED,
      InTransit: ParcelStatus.IN_TRANSIT,
      OutForDelivery: ParcelStatus.OUT_FOR_DELIVERY,
      Delivered: ParcelStatus.DELIVERED,
      FailedAttempt: ParcelStatus.FAILED_ATTEMPT,
      AvailableForPickup: ParcelStatus.OUT_FOR_DELIVERY,
      Exception: ParcelStatus.EXCEPTION,
      Expired: ParcelStatus.EXPIRED,
    };

    return statusMap[tag] || ParcelStatus.UNKNOWN;
  }

  private getAftershipSlug(carrier: CarrierType): string {
    const slugMap: Record<CarrierType, string> = {
      USPS: 'usps',
      UPS: 'ups',
      FEDEX: 'fedex',
      DHL: 'dhl',
      DHL_EXPRESS: 'dhl-express',
      AMAZON: 'amazon-logistics',
      ROYAL_MAIL: 'royal-mail',
      CHINA_POST: 'china-post',
      YANWEN: 'yanwen',
      CAINIAO: 'cainiao',
      FOUR_PX: '4px',
      SF_EXPRESS: 'sf-express',
      JAPAN_POST: 'japan-post',
      KOREA_POST: 'korea-post',
      AUSTRALIA_POST: 'australia-post',
      CANADA_POST: 'canada-post',
      LA_POSTE: 'la-poste-colissimo',
      DEUTSCHE_POST: 'deutsche-post',
      POSTNL: 'postnl',
      CHRONOPOST: 'chronopost',
      GLS: 'gls',
      DPD: 'dpd',
      HERMES: 'hermes-uk',
      EVRI: 'evri-uk',
      YODEL: 'yodel',
      TNT: 'tnt',
      ARAMEX: 'aramex',
      OTHER: 'other',
    };

    return slugMap[carrier] || 'other';
  }
}
