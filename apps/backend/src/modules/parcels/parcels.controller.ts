import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
} from '@nestjs/swagger';

import { ParcelsService } from './parcels.service';
import { CreateParcelDto } from './dto/create-parcel.dto';
import { UpdateParcelDto } from './dto/update-parcel.dto';
import { ListParcelsQueryDto } from './dto/list-parcels-query.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('Parcels')
@Controller('parcels')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ParcelsController {
  constructor(private readonly parcelsService: ParcelsService) {}

  @Post()
  @ApiOperation({ summary: 'Add a new parcel to track' })
  @ApiResponse({ status: 201, description: 'Parcel created successfully' })
  @ApiResponse({ status: 409, description: 'Parcel already exists' })
  async create(
    @CurrentUser('id') userId: string,
    @Body() createParcelDto: CreateParcelDto,
  ) {
    return this.parcelsService.create(userId, createParcelDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all parcels for the current user' })
  @ApiResponse({ status: 200, description: 'Returns list of parcels' })
  async findAll(
    @CurrentUser('id') userId: string,
    @Query() query: ListParcelsQueryDto,
  ) {
    return this.parcelsService.findAll(userId, query);
  }

  @Get('stats')
  @ApiOperation({ summary: 'Get parcel statistics for the current user' })
  @ApiResponse({ status: 200, description: 'Returns parcel statistics' })
  async getStats(@CurrentUser('id') userId: string) {
    return this.parcelsService.getStats(userId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get detailed information for a specific parcel' })
  @ApiParam({ name: 'id', description: 'Parcel ID' })
  @ApiResponse({ status: 200, description: 'Returns parcel details' })
  @ApiResponse({ status: 404, description: 'Parcel not found' })
  async findOne(
    @CurrentUser('id') userId: string,
    @Param('id') parcelId: string,
  ) {
    return this.parcelsService.findOne(userId, parcelId);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update parcel preferences' })
  @ApiParam({ name: 'id', description: 'Parcel ID' })
  @ApiResponse({ status: 200, description: 'Parcel updated successfully' })
  @ApiResponse({ status: 404, description: 'Parcel not found' })
  async update(
    @CurrentUser('id') userId: string,
    @Param('id') parcelId: string,
    @Body() updateParcelDto: UpdateParcelDto,
  ) {
    return this.parcelsService.update(userId, parcelId, updateParcelDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a parcel' })
  @ApiParam({ name: 'id', description: 'Parcel ID' })
  @ApiResponse({ status: 204, description: 'Parcel deleted successfully' })
  @ApiResponse({ status: 404, description: 'Parcel not found' })
  async remove(
    @CurrentUser('id') userId: string,
    @Param('id') parcelId: string,
  ) {
    await this.parcelsService.remove(userId, parcelId);
  }

  @Post(':id/refresh')
  @ApiOperation({ summary: 'Manually refresh tracking information' })
  @ApiParam({ name: 'id', description: 'Parcel ID' })
  @ApiResponse({ status: 200, description: 'Tracking refreshed successfully' })
  @ApiResponse({ status: 404, description: 'Parcel not found' })
  async refresh(
    @CurrentUser('id') userId: string,
    @Param('id') parcelId: string,
  ) {
    return this.parcelsService.refresh(userId, parcelId);
  }

  @Post(':id/archive')
  @ApiOperation({ summary: 'Archive a parcel' })
  @ApiParam({ name: 'id', description: 'Parcel ID' })
  @ApiResponse({ status: 200, description: 'Parcel archived successfully' })
  async archive(
    @CurrentUser('id') userId: string,
    @Param('id') parcelId: string,
  ) {
    return this.parcelsService.archive(userId, parcelId);
  }

  @Post(':id/unarchive')
  @ApiOperation({ summary: 'Unarchive a parcel' })
  @ApiParam({ name: 'id', description: 'Parcel ID' })
  @ApiResponse({ status: 200, description: 'Parcel unarchived successfully' })
  async unarchive(
    @CurrentUser('id') userId: string,
    @Param('id') parcelId: string,
  ) {
    return this.parcelsService.unarchive(userId, parcelId);
  }
}
