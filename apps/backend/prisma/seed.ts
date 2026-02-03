import { PrismaClient, CarrierType, ParcelStatus } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');

  // Create demo user
  const hashedPassword = await bcrypt.hash('demo123456', 10);

  const demoUser = await prisma.user.upsert({
    where: { email: 'demo@example.com' },
    update: {},
    create: {
      email: 'demo@example.com',
      name: 'Demo User',
      password: hashedPassword,
      isEmailVerified: true,
      notificationsEnabled: true,
    },
  });

  console.log(`Created demo user: ${demoUser.email}`);

  // Create sample parcels for demo user
  const parcels = [
    {
      trackingNumber: '1Z999AA10123456784',
      carrier: CarrierType.UPS,
      carrierName: 'UPS',
      title: 'Electronics Order',
      description: 'New laptop and accessories',
      status: ParcelStatus.IN_TRANSIT,
      originCountry: 'US',
      destinationCountry: 'US',
    },
    {
      trackingNumber: '9400111899223456789012',
      carrier: CarrierType.USPS,
      carrierName: 'USPS',
      title: 'Amazon Package',
      description: 'Books and stationery',
      status: ParcelStatus.OUT_FOR_DELIVERY,
      originCountry: 'US',
      destinationCountry: 'US',
    },
    {
      trackingNumber: 'JD014600003698012345',
      carrier: CarrierType.DHL,
      carrierName: 'DHL Express',
      title: 'International Shipment',
      description: 'Gift from overseas',
      status: ParcelStatus.IN_TRANSIT,
      originCountry: 'DE',
      destinationCountry: 'US',
    },
  ];

  for (const parcelData of parcels) {
    const parcel = await prisma.parcel.upsert({
      where: {
        userId_trackingNumber_carrier: {
          userId: demoUser.id,
          trackingNumber: parcelData.trackingNumber,
          carrier: parcelData.carrier,
        },
      },
      update: {},
      create: {
        userId: demoUser.id,
        ...parcelData,
      },
    });

    // Create sample tracking events
    const events = [
      {
        status: 'Label Created',
        statusCode: 'INFO_RECEIVED',
        description: 'Shipping label has been created',
        location: 'Origin Facility',
        city: 'Los Angeles',
        country: 'US',
        timestamp: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
      },
      {
        status: 'Picked Up',
        statusCode: 'PICKED_UP',
        description: 'Package picked up by carrier',
        location: 'Local Post Office',
        city: 'Los Angeles',
        country: 'US',
        timestamp: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000),
      },
      {
        status: 'In Transit',
        statusCode: 'IN_TRANSIT',
        description: 'Package in transit to destination',
        location: 'Distribution Center',
        city: 'Phoenix',
        country: 'US',
        timestamp: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
      },
    ];

    for (const eventData of events) {
      await prisma.trackingEvent.create({
        data: {
          parcelId: parcel.id,
          ...eventData,
        },
      });
    }

    console.log(`Created parcel: ${parcel.trackingNumber}`);
  }

  console.log('Seeding completed!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
