import { Injectable } from '@nestjs/common';
import { CarrierType } from '@prisma/client';

interface CarrierPattern {
  carrier: CarrierType;
  patterns: RegExp[];
  name: string;
}

@Injectable()
export class CarrierDetectionService {
  private readonly carrierPatterns: CarrierPattern[] = [
    {
      carrier: CarrierType.USPS,
      name: 'USPS',
      patterns: [
        /^(94|93|92|91)[0-9]{20,22}$/,
        /^[A-Z]{2}[0-9]{9}US$/,
        /^(82|70)[0-9]{8}$/,
        /^[0-9]{20,22}$/,
      ],
    },
    {
      carrier: CarrierType.UPS,
      name: 'UPS',
      patterns: [
        /^1Z[A-Z0-9]{16}$/,
        /^T\d{10}$/,
        /^[0-9]{9}$/,
        /^[0-9]{26}$/,
      ],
    },
    {
      carrier: CarrierType.FEDEX,
      name: 'FedEx',
      patterns: [
        /^[0-9]{12}$/,
        /^[0-9]{15}$/,
        /^[0-9]{20}$/,
        /^[0-9]{22}$/,
        /^96[0-9]{20}$/,
        /^(DT|61)[0-9]{12}$/,
      ],
    },
    {
      carrier: CarrierType.DHL,
      name: 'DHL',
      patterns: [
        /^[0-9]{10,11}$/,
        /^[0-9]{3}[0-9]{8}[0-9]{0,2}$/,
        /^JD[0-9]{18}$/,
        /^GM[0-9]{16,18}$/,
        /^LX[0-9]{9}[A-Z]{2}$/,
      ],
    },
    {
      carrier: CarrierType.DHL_EXPRESS,
      name: 'DHL Express',
      patterns: [
        /^[0-9]{10}$/,
        /^[0-9]{9}$/,
        /^[A-Z]{3}[0-9]{7}$/,
      ],
    },
    {
      carrier: CarrierType.AMAZON,
      name: 'Amazon Logistics',
      patterns: [
        /^TBA[0-9]{12,15}$/i,
        /^TBM[0-9]{12,15}$/i,
        /^TBC[0-9]{12,15}$/i,
      ],
    },
    {
      carrier: CarrierType.ROYAL_MAIL,
      name: 'Royal Mail',
      patterns: [
        /^[A-Z]{2}[0-9]{9}GB$/,
        /^[0-9]{13}$/,
        /^[A-Z]{2}[0-9]{9}[A-Z]{2}$/,
      ],
    },
    {
      carrier: CarrierType.CHINA_POST,
      name: 'China Post',
      patterns: [
        /^[A-Z]{2}[0-9]{9}CN$/,
        /^R[A-Z][0-9]{9}CN$/,
        /^E[A-Z][0-9]{9}CN$/,
        /^L[A-Z][0-9]{9}CN$/,
      ],
    },
    {
      carrier: CarrierType.YANWEN,
      name: 'Yanwen',
      patterns: [
        /^Y[A-Z][0-9]{9}[A-Z]{2}$/,
        /^[A-Z]{2}[0-9]{9}YP$/,
        /^S[0-9]{12}$/,
      ],
    },
    {
      carrier: CarrierType.CAINIAO,
      name: 'Cainiao',
      patterns: [
        /^LP[0-9]{14,18}$/,
        /^[0-9]{18}$/,
      ],
    },
    {
      carrier: CarrierType.FOUR_PX,
      name: '4PX',
      patterns: [
        /^4PX[A-Z0-9]+$/i,
        /^U[0-9]{10,12}$/,
      ],
    },
    {
      carrier: CarrierType.SF_EXPRESS,
      name: 'SF Express',
      patterns: [
        /^SF[0-9]{13}$/,
        /^[0-9]{12}$/,
        /^[0-9]{15}$/,
      ],
    },
    {
      carrier: CarrierType.JAPAN_POST,
      name: 'Japan Post',
      patterns: [
        /^[A-Z]{2}[0-9]{9}JP$/,
      ],
    },
    {
      carrier: CarrierType.KOREA_POST,
      name: 'Korea Post',
      patterns: [
        /^[A-Z]{2}[0-9]{9}KR$/,
      ],
    },
    {
      carrier: CarrierType.AUSTRALIA_POST,
      name: 'Australia Post',
      patterns: [
        /^[A-Z]{2}[0-9]{9}AU$/,
        /^[0-9]{12,22}$/,
      ],
    },
    {
      carrier: CarrierType.CANADA_POST,
      name: 'Canada Post',
      patterns: [
        /^[A-Z]{2}[0-9]{9}CA$/,
        /^[0-9]{16}$/,
      ],
    },
    {
      carrier: CarrierType.LA_POSTE,
      name: 'La Poste',
      patterns: [
        /^[A-Z]{2}[0-9]{9}FR$/,
        /^[0-9]{11,15}$/,
      ],
    },
    {
      carrier: CarrierType.DEUTSCHE_POST,
      name: 'Deutsche Post',
      patterns: [
        /^[A-Z]{2}[0-9]{9}DE$/,
        /^[0-9]{12,20}$/,
      ],
    },
    {
      carrier: CarrierType.POSTNL,
      name: 'PostNL',
      patterns: [
        /^[A-Z]{2}[0-9]{9}NL$/,
        /^3S[A-Z0-9]{12,18}$/,
      ],
    },
    {
      carrier: CarrierType.CHRONOPOST,
      name: 'Chronopost',
      patterns: [
        /^[A-Z]{2}[0-9]{9}FR$/,
        /^[0-9]{13}$/,
      ],
    },
    {
      carrier: CarrierType.GLS,
      name: 'GLS',
      patterns: [
        /^[0-9]{11,12}$/,
      ],
    },
    {
      carrier: CarrierType.DPD,
      name: 'DPD',
      patterns: [
        /^[0-9]{14}$/,
        /^[0-9]{11}$/,
      ],
    },
    {
      carrier: CarrierType.HERMES,
      name: 'Hermes/Evri',
      patterns: [
        /^[0-9]{16}$/,
      ],
    },
    {
      carrier: CarrierType.EVRI,
      name: 'Evri',
      patterns: [
        /^[A-Z0-9]{16}$/,
      ],
    },
    {
      carrier: CarrierType.YODEL,
      name: 'Yodel',
      patterns: [
        /^JD[0-9]{16}$/,
        /^[0-9]{16}$/,
      ],
    },
    {
      carrier: CarrierType.TNT,
      name: 'TNT',
      patterns: [
        /^[0-9]{9}$/,
        /^GE[0-9]{9}[A-Z]{2}$/,
      ],
    },
    {
      carrier: CarrierType.ARAMEX,
      name: 'Aramex',
      patterns: [
        /^[0-9]{10}$/,
        /^[0-9]{11,13}$/,
      ],
    },
  ];

  detectCarrier(trackingNumber: string): { carrier: CarrierType; name: string } | null {
    const normalized = trackingNumber.toUpperCase().replace(/\s/g, '');

    for (const carrierPattern of this.carrierPatterns) {
      for (const pattern of carrierPattern.patterns) {
        if (pattern.test(normalized)) {
          return {
            carrier: carrierPattern.carrier,
            name: carrierPattern.name,
          };
        }
      }
    }

    return null;
  }

  detectPossibleCarriers(trackingNumber: string): Array<{ carrier: CarrierType; name: string }> {
    const normalized = trackingNumber.toUpperCase().replace(/\s/g, '');
    const matches: Array<{ carrier: CarrierType; name: string }> = [];

    for (const carrierPattern of this.carrierPatterns) {
      for (const pattern of carrierPattern.patterns) {
        if (pattern.test(normalized)) {
          matches.push({
            carrier: carrierPattern.carrier,
            name: carrierPattern.name,
          });
          break;
        }
      }
    }

    return matches;
  }

  getCarrierName(carrier: CarrierType): string {
    const found = this.carrierPatterns.find((p) => p.carrier === carrier);
    return found?.name || carrier.toString();
  }

  getAllCarriers(): Array<{ carrier: CarrierType; name: string }> {
    return this.carrierPatterns.map((p) => ({
      carrier: p.carrier,
      name: p.name,
    }));
  }
}
