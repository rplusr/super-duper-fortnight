import {
  Controller,
  Post,
  Delete,
  Body,
  Patch,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { IsString, IsBoolean, IsNotEmpty } from 'class-validator';

import { NotificationsService } from './notifications.service';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

class RegisterTokenDto {
  @IsString()
  @IsNotEmpty()
  token: string;
}

class UpdatePreferencesDto {
  @IsBoolean()
  enabled: boolean;
}

@ApiTags('notifications')
@ApiBearerAuth()
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Post('register-token')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Register device push token' })
  async registerToken(
    @CurrentUser('sub') userId: string,
    @Body() dto: RegisterTokenDto,
  ) {
    await this.notificationsService.registerPushToken(userId, dto.token);
    return { success: true, message: 'Push token registered' };
  }

  @Delete('unregister-token')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Unregister device push token' })
  async unregisterToken(@CurrentUser('sub') userId: string) {
    await this.notificationsService.unregisterPushToken(userId);
    return { success: true, message: 'Push token unregistered' };
  }

  @Patch('preferences')
  @ApiOperation({ summary: 'Update notification preferences' })
  async updatePreferences(
    @CurrentUser('sub') userId: string,
    @Body() dto: UpdatePreferencesDto,
  ) {
    await this.notificationsService.updateNotificationPreferences(
      userId,
      dto.enabled,
    );
    return { success: true, enabled: dto.enabled };
  }
}
