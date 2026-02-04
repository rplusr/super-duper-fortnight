import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { CarrierType, ParcelStatus } from '@prisma/client';

import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/prisma/prisma.service';

describe('Parcels API (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let authToken: string;
  let testUserId: string;

  const testUser = {
    email: 'test@example.com',
    password: 'TestPassword123!',
    name: 'Test User',
  };

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );
    app.setGlobalPrefix('api');
    await app.init();

    prisma = app.get(PrismaService);

    // Clean up test data
    await prisma.trackingEvent.deleteMany({});
    await prisma.parcel.deleteMany({});
    await prisma.refreshToken.deleteMany({});
    await prisma.user.deleteMany({ where: { email: testUser.email } });

    // Create test user and get auth token
    const registerResponse = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send(testUser)
      .expect(201);

    authToken = registerResponse.body.accessToken;
    testUserId = registerResponse.body.user.id;
  });

  afterAll(async () => {
    // Clean up
    await prisma.trackingEvent.deleteMany({});
    await prisma.parcel.deleteMany({});
    await prisma.refreshToken.deleteMany({});
    await prisma.user.deleteMany({ where: { email: testUser.email } });
    await app.close();
  });

  describe('POST /api/parcels', () => {
    it('should create a new parcel', async () => {
      const response = await request(app.getHttpServer())
        .post('/api/parcels')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          trackingNumber: '1Z999AA10123456784',
          carrier: CarrierType.UPS,
          title: 'Test Package',
        })
        .expect(201);

      expect(response.body).toMatchObject({
        trackingNumber: '1Z999AA10123456784',
        carrier: CarrierType.UPS,
        title: 'Test Package',
        status: ParcelStatus.PENDING,
      });
      expect(response.body.id).toBeDefined();
    });

    it('should auto-detect carrier if not provided', async () => {
      const response = await request(app.getHttpServer())
        .post('/api/parcels')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          trackingNumber: '9400111899223033005351',
          title: 'USPS Package',
        })
        .expect(201);

      expect(response.body.carrier).toBe(CarrierType.USPS);
    });

    it('should reject duplicate tracking numbers', async () => {
      // First create
      await request(app.getHttpServer())
        .post('/api/parcels')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          trackingNumber: 'DUPLICATE123456789',
          carrier: CarrierType.OTHER,
        })
        .expect(201);

      // Duplicate
      await request(app.getHttpServer())
        .post('/api/parcels')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          trackingNumber: 'DUPLICATE123456789',
          carrier: CarrierType.OTHER,
        })
        .expect(409);
    });

    it('should require authentication', async () => {
      await request(app.getHttpServer())
        .post('/api/parcels')
        .send({
          trackingNumber: '1Z999AA10123456784',
          carrier: CarrierType.UPS,
        })
        .expect(401);
    });

    it('should validate tracking number', async () => {
      await request(app.getHttpServer())
        .post('/api/parcels')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          trackingNumber: '',
          carrier: CarrierType.UPS,
        })
        .expect(400);
    });
  });

  describe('GET /api/parcels', () => {
    it('should list user parcels', async () => {
      const response = await request(app.getHttpServer())
        .get('/api/parcels')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body).toHaveProperty('data');
      expect(response.body).toHaveProperty('meta');
      expect(Array.isArray(response.body.data)).toBe(true);
    });

    it('should support pagination', async () => {
      const response = await request(app.getHttpServer())
        .get('/api/parcels?page=1&limit=10')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.meta.page).toBe(1);
      expect(response.body.meta.limit).toBe(10);
    });

    it('should filter by status', async () => {
      const response = await request(app.getHttpServer())
        .get(`/api/parcels?status=${ParcelStatus.PENDING}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      response.body.data.forEach((parcel: any) => {
        expect(parcel.status).toBe(ParcelStatus.PENDING);
      });
    });

    it('should require authentication', async () => {
      await request(app.getHttpServer())
        .get('/api/parcels')
        .expect(401);
    });
  });

  describe('GET /api/parcels/:id', () => {
    let parcelId: string;

    beforeAll(async () => {
      const response = await request(app.getHttpServer())
        .post('/api/parcels')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          trackingNumber: 'DETAIL123456789',
          carrier: CarrierType.FEDEX,
          title: 'Detail Test',
        });
      parcelId = response.body.id;
    });

    it('should get parcel by id', async () => {
      const response = await request(app.getHttpServer())
        .get(`/api/parcels/${parcelId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.id).toBe(parcelId);
      expect(response.body.trackingNumber).toBe('DETAIL123456789');
    });

    it('should return 404 for non-existent parcel', async () => {
      await request(app.getHttpServer())
        .get('/api/parcels/non-existent-id')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(404);
    });

    it('should require authentication', async () => {
      await request(app.getHttpServer())
        .get(`/api/parcels/${parcelId}`)
        .expect(401);
    });
  });

  describe('PATCH /api/parcels/:id', () => {
    let parcelId: string;

    beforeAll(async () => {
      const response = await request(app.getHttpServer())
        .post('/api/parcels')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          trackingNumber: 'UPDATE123456789',
          carrier: CarrierType.DHL,
          title: 'Update Test',
        });
      parcelId = response.body.id;
    });

    it('should update parcel', async () => {
      const response = await request(app.getHttpServer())
        .patch(`/api/parcels/${parcelId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          title: 'Updated Title',
          description: 'Updated description',
        })
        .expect(200);

      expect(response.body.title).toBe('Updated Title');
      expect(response.body.description).toBe('Updated description');
    });

    it('should require authentication', async () => {
      await request(app.getHttpServer())
        .patch(`/api/parcels/${parcelId}`)
        .send({ title: 'New Title' })
        .expect(401);
    });
  });

  describe('DELETE /api/parcels/:id', () => {
    let parcelId: string;

    beforeEach(async () => {
      const response = await request(app.getHttpServer())
        .post('/api/parcels')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          trackingNumber: `DELETE${Date.now()}`,
          carrier: CarrierType.OTHER,
        });
      parcelId = response.body.id;
    });

    it('should delete parcel', async () => {
      await request(app.getHttpServer())
        .delete(`/api/parcels/${parcelId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      // Verify deleted
      await request(app.getHttpServer())
        .get(`/api/parcels/${parcelId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(404);
    });

    it('should require authentication', async () => {
      await request(app.getHttpServer())
        .delete(`/api/parcels/${parcelId}`)
        .expect(401);
    });
  });

  describe('GET /api/parcels/stats', () => {
    it('should return parcel stats', async () => {
      const response = await request(app.getHttpServer())
        .get('/api/parcels/stats')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body).toHaveProperty('total');
      expect(response.body).toHaveProperty('inTransit');
      expect(response.body).toHaveProperty('delivered');
      expect(response.body).toHaveProperty('pending');
      expect(response.body).toHaveProperty('exception');
    });

    it('should require authentication', async () => {
      await request(app.getHttpServer())
        .get('/api/parcels/stats')
        .expect(401);
    });
  });

  describe('POST /api/parcels/:id/refresh', () => {
    let parcelId: string;

    beforeAll(async () => {
      const response = await request(app.getHttpServer())
        .post('/api/parcels')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          trackingNumber: 'REFRESH123456789',
          carrier: CarrierType.UPS,
        });
      parcelId = response.body.id;
    });

    it('should trigger tracking refresh', async () => {
      const response = await request(app.getHttpServer())
        .post(`/api/parcels/${parcelId}/refresh`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.id).toBe(parcelId);
    });

    it('should require authentication', async () => {
      await request(app.getHttpServer())
        .post(`/api/parcels/${parcelId}/refresh`)
        .expect(401);
    });
  });
});
