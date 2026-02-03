import { Module } from '@nestjs/common';

import { ParcelsController } from './parcels.controller';
import { ParcelsService } from './parcels.service';
import { TrackingModule } from '../tracking/tracking.module';

@Module({
  imports: [TrackingModule],
  controllers: [ParcelsController],
  providers: [ParcelsService],
  exports: [ParcelsService],
})
export class ParcelsModule {}
