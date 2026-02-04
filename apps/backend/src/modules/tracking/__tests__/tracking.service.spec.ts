import { Test, TestingModule } from '@nestjs/testing';
import { ParcelStatus, CarrierType } from '@prisma/client';

import { TrackingService } from '../tracking.service';
import { PrismaService } from '../../../prisma/prisma.service';
import { AftershipClient, TrackingInfo } from '../clients/aftership.client';
import { CarrierDetectionService } from '../carrier-detection.service';
import { EventsGateway } from '../../events/events.gateway';
import { NotificationsService } from '../../notifications/notifications.service';

describe('TrackingService', () => {
  let service: TrackingService;
  let prismaService: jest.Mocked<PrismaService>;
  let aftershipClient: jest.Mocked<AftershipClient>;
  let carrierDetectionService: jest.Mocked<CarrierDetectionService>;
  let eventsGateway: jest.Mocked<EventsGateway>;
  let notificationsService: jest.Mocked<NotificationsService>;

  const mockParcel = {
    id: 'parcel-123',
    userId: 'user-123',
    trackingNumber: '1Z999AA10123456784',
    carrier: CarrierType.UPS,
    carrierName: 'UPS',
    title: 'Test Parcel',
    description: null,
    status: ParcelStatus.IN_TRANSIT,
    estimatedDelivery: null,
    originCountry: null,
    destinationCountry: null,
    weight: null,
    notifyOnUpdate: true,
    notifyOnDelivery: true,
    isArchived: false,
    lastSyncAt: null,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  const mockTrackingInfo: TrackingInfo = {
    slug: 'ups',
    trackingNumber: '1Z999AA10123456784',
    tag: 'InTransit',
    subtag: 'InTransit_001',
    message: 'Package in transit',
    expectedDelivery: '2024-01-15',
    originCountryIso3: 'USA',
    destinationCountryIso3: 'USA',
    checkpoints: [
      {
        slug: 'ups',
        tag: 'InTransit',
        subtag: 'InTransit_001',
        message: 'Package departed facility',
        location: 'Chicago, IL',
        city: 'Chicago',
        countryName: 'United States',
        countryIso3: 'USA',
        checkpointTime: '2024-01-10T10:00:00Z',
        rawStatus: 'Departed',
      },
    ],
  };

  beforeEach(async () => {
    const mockPrisma = {
      parcel: {
        findUnique: jest.fn(),
        update: jest.fn(),
      },
      trackingEvent: {
        findMany: jest.fn(),
        createMany: jest.fn(),
      },
    };

    const mockAftershipClient = {
      getTracking: jest.fn(),
    };

    const mockCarrierDetection = {
      detectCarrier: jest.fn(),
      getCarrierName: jest.fn(),
    };

    const mockEventsGateway = {
      emitParcelUpdate: jest.fn(),
      emitStatusChange: jest.fn(),
      emitNewTrackingEvent: jest.fn(),
    };

    const mockNotificationsService = {
      sendParcelStatusNotification: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        TrackingService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: AftershipClient, useValue: mockAftershipClient },
        { provide: CarrierDetectionService, useValue: mockCarrierDetection },
        { provide: EventsGateway, useValue: mockEventsGateway },
        { provide: NotificationsService, useValue: mockNotificationsService },
      ],
    }).compile();

    service = module.get<TrackingService>(TrackingService);
    prismaService = module.get(PrismaService);
    aftershipClient = module.get(AftershipClient);
    carrierDetectionService = module.get(CarrierDetectionService);
    eventsGateway = module.get(EventsGateway);
    notificationsService = module.get(NotificationsService);
  });

  describe('trackParcel', () => {
    it('should track a parcel with provided carrier', async () => {
      aftershipClient.getTracking.mockResolvedValue(mockTrackingInfo);

      const result = await service.trackParcel('1Z999AA10123456784', CarrierType.UPS);

      expect(result).toEqual(mockTrackingInfo);
      expect(aftershipClient.getTracking).toHaveBeenCalledWith(
        '1Z999AA10123456784',
        'ups',
      );
    });

    it('should auto-detect carrier if not provided', async () => {
      carrierDetectionService.detectCarrier.mockReturnValue({
        carrier: CarrierType.UPS,
        name: 'UPS',
      });
      aftershipClient.getTracking.mockResolvedValue(mockTrackingInfo);

      const result = await service.trackParcel('1Z999AA10123456784');

      expect(carrierDetectionService.detectCarrier).toHaveBeenCalledWith(
        '1Z999AA10123456784',
      );
      expect(result).toEqual(mockTrackingInfo);
    });

    it('should return null if tracking API fails', async () => {
      aftershipClient.getTracking.mockRejectedValue(new Error('API error'));

      const result = await service.trackParcel('1Z999AA10123456784', CarrierType.UPS);

      expect(result).toBeNull();
    });
  });

  describe('syncParcelTracking', () => {
    beforeEach(() => {
      (prismaService.parcel.findUnique as jest.Mock).mockResolvedValue(mockParcel);
      (prismaService.parcel.update as jest.Mock).mockResolvedValue({
        ...mockParcel,
        status: ParcelStatus.IN_TRANSIT,
        lastSyncAt: new Date(),
      });
      (prismaService.trackingEvent.findMany as jest.Mock).mockResolvedValue([]);
      (prismaService.trackingEvent.createMany as jest.Mock).mockResolvedValue({ count: 1 });
      aftershipClient.getTracking.mockResolvedValue(mockTrackingInfo);
    });

    it('should sync tracking for a parcel', async () => {
      const result = await service.syncParcelTracking('parcel-123');

      expect(result.success).toBe(true);
      expect(result.parcel).toBeDefined();
      expect(prismaService.parcel.update).toHaveBeenCalled();
    });

    it('should return error if parcel not found', async () => {
      (prismaService.parcel.findUnique as jest.Mock).mockResolvedValue(null);

      const result = await service.syncParcelTracking('invalid-id');

      expect(result.success).toBe(false);
      expect(result.error).toBe('Parcel not found');
    });

    it('should emit WebSocket event on status change', async () => {
      const pendingParcel = { ...mockParcel, status: ParcelStatus.PENDING };
      (prismaService.parcel.findUnique as jest.Mock).mockResolvedValue(pendingParcel);

      await service.syncParcelTracking('parcel-123');

      expect(eventsGateway.emitStatusChange).toHaveBeenCalledWith(
        'user-123',
        'parcel-123',
        ParcelStatus.PENDING,
        ParcelStatus.IN_TRANSIT,
      );
    });

    it('should send push notification on status change', async () => {
      const pendingParcel = { ...mockParcel, status: ParcelStatus.PENDING };
      (prismaService.parcel.findUnique as jest.Mock).mockResolvedValue(pendingParcel);

      await service.syncParcelTracking('parcel-123');

      expect(notificationsService.sendParcelStatusNotification).toHaveBeenCalledWith(
        'user-123',
        'parcel-123',
        'Test Parcel',
        ParcelStatus.PENDING,
        ParcelStatus.IN_TRANSIT,
      );
    });

    it('should create new tracking events', async () => {
      (prismaService.parcel.findUnique as jest.Mock)
        .mockResolvedValueOnce(mockParcel)
        .mockResolvedValueOnce({ userId: 'user-123' });

      await service.syncParcelTracking('parcel-123');

      expect(prismaService.trackingEvent.createMany).toHaveBeenCalled();
    });

    it('should not create duplicate tracking events', async () => {
      const existingEvent = {
        timestamp: new Date('2024-01-10T10:00:00Z'),
        statusCode: 'InTransit',
      };
      (prismaService.trackingEvent.findMany as jest.Mock).mockResolvedValue([existingEvent]);

      await service.syncParcelTracking('parcel-123');

      expect(prismaService.trackingEvent.createMany).not.toHaveBeenCalled();
    });

    it('should return error if tracking API fails', async () => {
      aftershipClient.getTracking.mockResolvedValue(null);

      const result = await service.syncParcelTracking('parcel-123');

      expect(result.success).toBe(false);
      expect(result.error).toBe('Unable to fetch tracking information');
    });
  });
});
