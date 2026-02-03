import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsBoolean, IsOptional, IsString, MaxLength } from 'class-validator';

export class UpdateParcelDto {
  @ApiPropertyOptional({
    example: 'Updated title',
    description: 'Custom title for the parcel',
  })
  @IsString()
  @IsOptional()
  @MaxLength(200)
  title?: string;

  @ApiPropertyOptional({
    example: 'Updated description',
    description: 'Description of the parcel contents',
  })
  @IsString()
  @IsOptional()
  @MaxLength(500)
  description?: string;

  @ApiPropertyOptional({
    example: true,
    description: 'Whether to receive notifications on status updates',
  })
  @IsBoolean()
  @IsOptional()
  notifyOnUpdate?: boolean;

  @ApiPropertyOptional({
    example: true,
    description: 'Whether to receive notifications when delivered',
  })
  @IsBoolean()
  @IsOptional()
  notifyOnDelivery?: boolean;

  @ApiPropertyOptional({
    example: false,
    description: 'Whether the parcel is archived',
  })
  @IsBoolean()
  @IsOptional()
  isArchived?: boolean;
}
