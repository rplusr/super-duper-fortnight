import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { TrackingService } from './tracking.service';
import { CarrierDetectionService } from './carrier-detection.service';
import { AftershipClient } from './clients/aftership.client';
import { TrackingController } from './tracking.controller';

@Module({
  imports: [ConfigModule],
  controllers: [TrackingController],
  providers: [TrackingService, CarrierDetectionService, AftershipClient],
  exports: [TrackingService, CarrierDetectionService],
})
export class TrackingModule {}
