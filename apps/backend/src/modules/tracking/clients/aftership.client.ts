import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios, { AxiosInstance } from 'axios';
import axiosRetry from 'axios-retry';

export interface TrackingCheckpoint {
  slug: string;
  city: string;
  createdAt: string;
  location: string;
  countryName: string;
  message: string;
  countryIso3: string;
  tag: string;
  subtag: string;
  subtagMessage: string;
  checkpointTime: string;
  state: string;
  zip: string;
  rawTag: string;
}

export interface TrackingInfo {
  id: string;
  trackingNumber: string;
  slug: string;
  active: boolean;
  tag: string;
  subtag: string;
  subtagMessage: string;
  title: string;
  expectedDelivery: string | null;
  shipmentPackageCount: number;
  originCountryIso3: string;
  destinationCountryIso3: string;
  shipmentWeight: number | null;
  shipmentWeightUnit: string;
  signedBy: string;
  deliveryTime: number | null;
  checkpoints: TrackingCheckpoint[];
}

interface AftershipResponse<T> {
  meta: {
    code: number;
    message?: string;
  };
  data: T;
}

@Injectable()
export class AftershipClient {
  private readonly logger = new Logger(AftershipClient.name);
  private readonly client: AxiosInstance;
  private readonly apiKey: string;

  constructor(private readonly configService: ConfigService) {
    this.apiKey = this.configService.get<string>('AFTERSHIP_API_KEY', '');

    this.client = axios.create({
      baseURL: 'https://api.aftership.com/v4',
      headers: {
        'Content-Type': 'application/json',
        'aftership-api-key': this.apiKey,
      },
      timeout: 30000,
    });

    // Configure retry logic
    axiosRetry(this.client, {
      retries: 3,
      retryDelay: axiosRetry.exponentialDelay,
      retryCondition: (error) => {
        return (
          axiosRetry.isNetworkOrIdempotentRequestError(error) ||
          error.response?.status === 429 ||
          (error.response?.status ?? 0) >= 500
        );
      },
      onRetry: (retryCount, error) => {
        this.logger.warn(
          `Retrying Aftership request (attempt ${retryCount}): ${error.message}`,
        );
      },
    });
  }

  async createTracking(
    trackingNumber: string,
    slug?: string,
    title?: string,
  ): Promise<TrackingInfo> {
    try {
      const response = await this.client.post<AftershipResponse<{ tracking: TrackingInfo }>>(
        '/trackings',
        {
          tracking: {
            tracking_number: trackingNumber,
            slug,
            title,
          },
        },
      );

      return response.data.data.tracking;
    } catch (error) {
      this.logger.error(`Failed to create tracking for ${trackingNumber}:`, error);
      throw error;
    }
  }

  async getTracking(
    trackingNumber: string,
    slug?: string,
  ): Promise<TrackingInfo | null> {
    try {
      let url = `/trackings/${slug}/${trackingNumber}`;

      if (!slug) {
        // Try to detect carrier first
        const detectResponse = await this.detectCarrier(trackingNumber);
        if (detectResponse && detectResponse.length > 0) {
          slug = detectResponse[0].slug;
          url = `/trackings/${slug}/${trackingNumber}`;
        } else {
          // Use tracking number only endpoint
          url = `/trackings/${trackingNumber}`;
        }
      }

      const response = await this.client.get<AftershipResponse<{ tracking: TrackingInfo }>>(url);

      return this.transformTracking(response.data.data.tracking);
    } catch (error: any) {
      if (error.response?.status === 404) {
        // Tracking not found, try to create it
        try {
          await this.createTracking(trackingNumber, slug);
          // Wait a moment for tracking to be processed
          await new Promise((resolve) => setTimeout(resolve, 2000));
          return this.getTracking(trackingNumber, slug);
        } catch (createError) {
          this.logger.warn(`Tracking ${trackingNumber} not found and couldn't be created`);
          return null;
        }
      }
      this.logger.error(`Failed to get tracking for ${trackingNumber}:`, error);
      throw error;
    }
  }

  async detectCarrier(
    trackingNumber: string,
  ): Promise<Array<{ slug: string; name: string }>> {
    try {
      const response = await this.client.post<
        AftershipResponse<{ couriers: Array<{ slug: string; name: string }> }>
      >('/couriers/detect', {
        tracking: {
          tracking_number: trackingNumber,
        },
      });

      return response.data.data.couriers;
    } catch (error) {
      this.logger.error(`Failed to detect carrier for ${trackingNumber}:`, error);
      return [];
    }
  }

  async deleteTracking(trackingNumber: string, slug: string): Promise<void> {
    try {
      await this.client.delete(`/trackings/${slug}/${trackingNumber}`);
    } catch (error) {
      this.logger.error(`Failed to delete tracking for ${trackingNumber}:`, error);
      throw error;
    }
  }

  private transformTracking(raw: any): TrackingInfo {
    return {
      id: raw.id,
      trackingNumber: raw.tracking_number,
      slug: raw.slug,
      active: raw.active,
      tag: raw.tag,
      subtag: raw.subtag,
      subtagMessage: raw.subtag_message,
      title: raw.title,
      expectedDelivery: raw.expected_delivery,
      shipmentPackageCount: raw.shipment_package_count,
      originCountryIso3: raw.origin_country_iso3,
      destinationCountryIso3: raw.destination_country_iso3,
      shipmentWeight: raw.shipment_weight,
      shipmentWeightUnit: raw.shipment_weight_unit,
      signedBy: raw.signed_by,
      deliveryTime: raw.delivery_time,
      checkpoints: (raw.checkpoints || []).map((cp: any) => ({
        slug: cp.slug,
        city: cp.city,
        createdAt: cp.created_at,
        location: cp.location,
        countryName: cp.country_name,
        message: cp.message,
        countryIso3: cp.country_iso3,
        tag: cp.tag,
        subtag: cp.subtag,
        subtagMessage: cp.subtag_message,
        checkpointTime: cp.checkpoint_time,
        state: cp.state,
        zip: cp.zip,
        rawTag: cp.raw_tag,
      })),
    };
  }
}
