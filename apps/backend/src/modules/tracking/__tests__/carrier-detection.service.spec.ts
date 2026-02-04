import { CarrierType } from '@prisma/client';
import { CarrierDetectionService } from '../carrier-detection.service';

describe('CarrierDetectionService', () => {
  let service: CarrierDetectionService;

  beforeEach(() => {
    service = new CarrierDetectionService();
  });

  describe('detectCarrier', () => {
    it('should detect USPS tracking numbers', () => {
      const testCases = [
        '9400111899223033005351',
        '9205590100130202081230',
        '92055901000000000000000000',
      ];

      for (const trackingNumber of testCases) {
        const result = service.detectCarrier(trackingNumber);
        expect(result).toBeDefined();
        expect(result?.carrier).toBe(CarrierType.USPS);
      }
    });

    it('should detect UPS tracking numbers', () => {
      const testCases = [
        '1Z999AA10123456784',
        '1Z12345E0291980793',
      ];

      for (const trackingNumber of testCases) {
        const result = service.detectCarrier(trackingNumber);
        expect(result).toBeDefined();
        expect(result?.carrier).toBe(CarrierType.UPS);
      }
    });

    it('should detect FedEx tracking numbers', () => {
      const testCases = [
        '123456789012',
        '1234567890123456789012',
      ];

      for (const trackingNumber of testCases) {
        const result = service.detectCarrier(trackingNumber);
        expect(result).toBeDefined();
        expect(result?.carrier).toBe(CarrierType.FEDEX);
      }
    });

    it('should detect DHL tracking numbers', () => {
      const testCases = [
        '1234567890',
        '123456789012345678',
      ];

      for (const trackingNumber of testCases) {
        const result = service.detectCarrier(trackingNumber);
        expect(result).toBeDefined();
        // DHL or DHL Express
        expect([CarrierType.DHL, CarrierType.DHL_EXPRESS]).toContain(
          result?.carrier,
        );
      }
    });

    it('should detect Amazon tracking numbers', () => {
      const testCases = ['TBA123456789000'];

      for (const trackingNumber of testCases) {
        const result = service.detectCarrier(trackingNumber);
        expect(result).toBeDefined();
        expect(result?.carrier).toBe(CarrierType.AMAZON);
      }
    });

    it('should return null for unrecognized tracking numbers', () => {
      const result = service.detectCarrier('INVALID123');
      expect(result).toBeNull();
    });

    it('should handle empty tracking numbers', () => {
      const result = service.detectCarrier('');
      expect(result).toBeNull();
    });

    it('should normalize tracking numbers (remove spaces)', () => {
      const result = service.detectCarrier('1Z 999 AA1 0123 4567 84');
      expect(result).toBeDefined();
      expect(result?.carrier).toBe(CarrierType.UPS);
    });
  });

  describe('getCarrierName', () => {
    it('should return display name for known carriers', () => {
      expect(service.getCarrierName(CarrierType.USPS)).toBe('USPS');
      expect(service.getCarrierName(CarrierType.UPS)).toBe('UPS');
      expect(service.getCarrierName(CarrierType.FEDEX)).toBe('FedEx');
      expect(service.getCarrierName(CarrierType.DHL)).toBe('DHL');
      expect(service.getCarrierName(CarrierType.DHL_EXPRESS)).toBe('DHL Express');
      expect(service.getCarrierName(CarrierType.AMAZON)).toBe('Amazon Logistics');
    });

    it('should return "Other" for unknown carrier type', () => {
      expect(service.getCarrierName(CarrierType.OTHER)).toBe('Other');
    });
  });
});
