import {
  Injectable,
  NotFoundException,
  ConflictException,
  ForbiddenException,
} from '@nestjs/common';
import { Parcel, ParcelStatus, CarrierType } from '@prisma/client';

import { PrismaService } from '../../prisma/prisma.service';
import { TrackingService } from '../tracking/tracking.service';
import { CarrierDetectionService } from '../tracking/carrier-detection.service';
import { CreateParcelDto } from './dto/create-parcel.dto';
import { UpdateParcelDto } from './dto/update-parcel.dto';
import { ListParcelsQueryDto } from './dto/list-parcels-query.dto';

export interface ParcelWithEvents extends Parcel {
  trackingEvents: Array<{
    id: string;
    status: string;
    statusCode: string | null;
    description: string;
    location: string | null;
    city: string | null;
    country: string | null;
    timestamp: Date;
  }>;
}

export interface PaginatedParcels {
  data: Parcel[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

@Injectable()
export class ParcelsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly trackingService: TrackingService,
    private readonly carrierDetectionService: CarrierDetectionService,
  ) {}

  async create(userId: string, createParcelDto: CreateParcelDto): Promise<ParcelWithEvents> {
    const { trackingNumber, carrier, title, description } = createParcelDto;

    // Auto-detect carrier if not provided
    let detectedCarrier = carrier;
    let carrierName: string | undefined;

    if (!detectedCarrier) {
      const detection = this.carrierDetectionService.detectCarrier(trackingNumber);
      if (detection) {
        detectedCarrier = detection.carrier;
        carrierName = detection.name;
      } else {
        detectedCarrier = CarrierType.OTHER;
        carrierName = 'Unknown Carrier';
      }
    } else {
      carrierName = this.carrierDetectionService.getCarrierName(detectedCarrier);
    }

    // Check for duplicate
    const existing = await this.prisma.parcel.findUnique({
      where: {
        userId_trackingNumber_carrier: {
          userId,
          trackingNumber: trackingNumber.toUpperCase().replace(/\s/g, ''),
          carrier: detectedCarrier,
        },
      },
    });

    if (existing) {
      throw new ConflictException('This tracking number is already being tracked');
    }

    // Create parcel
    const parcel = await this.prisma.parcel.create({
      data: {
        userId,
        trackingNumber: trackingNumber.toUpperCase().replace(/\s/g, ''),
        carrier: detectedCarrier,
        carrierName,
        title,
        description,
        status: ParcelStatus.PENDING,
      },
      include: {
        trackingEvents: {
          orderBy: { timestamp: 'desc' },
          select: {
            id: true,
            status: true,
            statusCode: true,
            description: true,
            location: true,
            city: true,
            country: true,
            timestamp: true,
          },
        },
      },
    });

    // Trigger async tracking sync
    this.trackingService.syncParcelTracking(parcel.id).catch((err) => {
      console.error('Failed to sync initial tracking:', err);
    });

    return parcel;
  }

  async findAll(userId: string, query: ListParcelsQueryDto): Promise<PaginatedParcels> {
    const {
      page = 1,
      limit = 20,
      status,
      carrier,
      search,
      archived,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = query;

    const where: any = {
      userId,
      isArchived: archived ?? false,
    };

    if (status) {
      where.status = status;
    }

    if (carrier) {
      where.carrier = carrier;
    }

    if (search) {
      where.OR = [
        { trackingNumber: { contains: search, mode: 'insensitive' } },
        { title: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [total, data] = await Promise.all([
      this.prisma.parcel.count({ where }),
      this.prisma.parcel.findMany({
        where,
        orderBy: { [sortBy]: sortOrder },
        skip: (page - 1) * limit,
        take: limit,
        include: {
          trackingEvents: {
            orderBy: { timestamp: 'desc' },
            take: 1,
            select: {
              id: true,
              status: true,
              description: true,
              location: true,
              timestamp: true,
            },
          },
        },
      }),
    ]);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(userId: string, parcelId: string): Promise<ParcelWithEvents> {
    const parcel = await this.prisma.parcel.findUnique({
      where: { id: parcelId },
      include: {
        trackingEvents: {
          orderBy: { timestamp: 'desc' },
          select: {
            id: true,
            status: true,
            statusCode: true,
            description: true,
            location: true,
            city: true,
            country: true,
            timestamp: true,
          },
        },
      },
    });

    if (!parcel) {
      throw new NotFoundException('Parcel not found');
    }

    if (parcel.userId !== userId) {
      throw new ForbiddenException('You do not have access to this parcel');
    }

    return parcel;
  }

  async update(
    userId: string,
    parcelId: string,
    updateParcelDto: UpdateParcelDto,
  ): Promise<Parcel> {
    const parcel = await this.prisma.parcel.findUnique({
      where: { id: parcelId },
    });

    if (!parcel) {
      throw new NotFoundException('Parcel not found');
    }

    if (parcel.userId !== userId) {
      throw new ForbiddenException('You do not have access to this parcel');
    }

    return this.prisma.parcel.update({
      where: { id: parcelId },
      data: updateParcelDto,
    });
  }

  async remove(userId: string, parcelId: string): Promise<void> {
    const parcel = await this.prisma.parcel.findUnique({
      where: { id: parcelId },
    });

    if (!parcel) {
      throw new NotFoundException('Parcel not found');
    }

    if (parcel.userId !== userId) {
      throw new ForbiddenException('You do not have access to this parcel');
    }

    await this.prisma.parcel.delete({
      where: { id: parcelId },
    });
  }

  async refresh(userId: string, parcelId: string): Promise<ParcelWithEvents> {
    const parcel = await this.prisma.parcel.findUnique({
      where: { id: parcelId },
    });

    if (!parcel) {
      throw new NotFoundException('Parcel not found');
    }

    if (parcel.userId !== userId) {
      throw new ForbiddenException('You do not have access to this parcel');
    }

    await this.trackingService.syncParcelTracking(parcelId);

    return this.findOne(userId, parcelId);
  }

  async archive(userId: string, parcelId: string): Promise<Parcel> {
    return this.update(userId, parcelId, { isArchived: true });
  }

  async unarchive(userId: string, parcelId: string): Promise<Parcel> {
    return this.update(userId, parcelId, { isArchived: false });
  }

  async getStats(userId: string): Promise<{
    total: number;
    inTransit: number;
    delivered: number;
    pending: number;
    exception: number;
  }> {
    const [total, inTransit, delivered, pending, exception] = await Promise.all([
      this.prisma.parcel.count({ where: { userId, isArchived: false } }),
      this.prisma.parcel.count({
        where: {
          userId,
          isArchived: false,
          status: { in: [ParcelStatus.IN_TRANSIT, ParcelStatus.OUT_FOR_DELIVERY] },
        },
      }),
      this.prisma.parcel.count({
        where: { userId, isArchived: false, status: ParcelStatus.DELIVERED },
      }),
      this.prisma.parcel.count({
        where: {
          userId,
          isArchived: false,
          status: { in: [ParcelStatus.PENDING, ParcelStatus.INFO_RECEIVED] },
        },
      }),
      this.prisma.parcel.count({
        where: {
          userId,
          isArchived: false,
          status: { in: [ParcelStatus.EXCEPTION, ParcelStatus.FAILED_ATTEMPT] },
        },
      }),
    ]);

    return { total, inTransit, delivered, pending, exception };
  }
}
