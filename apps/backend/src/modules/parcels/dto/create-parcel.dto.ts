import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsOptional,
  IsString,
  IsEnum,
  MaxLength,
  MinLength,
} from 'class-validator';
import { CarrierType } from '@prisma/client';

export class CreateParcelDto {
  @ApiProperty({
    example: '1Z999AA10123456784',
    description: 'Tracking number from the carrier',
  })
  @IsString()
  @IsNotEmpty({ message: 'Tracking number is required' })
  @MinLength(5, { message: 'Tracking number must be at least 5 characters' })
  @MaxLength(100)
  trackingNumber: string;

  @ApiPropertyOptional({
    enum: CarrierType,
    example: 'UPS',
    description: 'Carrier type (auto-detected if not provided)',
  })
  @IsEnum(CarrierType)
  @IsOptional()
  carrier?: CarrierType;

  @ApiPropertyOptional({
    example: 'My Amazon Order',
    description: 'Custom title for the parcel',
  })
  @IsString()
  @IsOptional()
  @MaxLength(200)
  title?: string;

  @ApiPropertyOptional({
    example: 'Electronics and accessories',
    description: 'Description of the parcel contents',
  })
  @IsString()
  @IsOptional()
  @MaxLength(500)
  description?: string;
}
