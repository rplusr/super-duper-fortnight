import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsBoolean, IsOptional, IsString, MaxLength } from 'class-validator';

export class UpdateProfileDto {
  @ApiPropertyOptional({
    example: 'John Doe',
    description: 'User full name',
  })
  @IsString()
  @IsOptional()
  @MaxLength(100)
  name?: string;

  @ApiPropertyOptional({
    example: 'ExponentPushToken[xxxxx]',
    description: 'Push notification token',
  })
  @IsString()
  @IsOptional()
  pushToken?: string;

  @ApiPropertyOptional({
    example: true,
    description: 'Whether push notifications are enabled',
  })
  @IsBoolean()
  @IsOptional()
  notificationsEnabled?: boolean;
}
