import {
  Controller,
  Post,
  Delete,
  Param,
  Body,
  UseGuards,
  Request,
  Get,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('users')
@Controller('users')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Post(':id/fcmToken')
  @ApiOperation({ summary: 'Register FCM token for push notifications' })
  async registerFcmToken(
    @Param('id') userId: string,
    @Body() body: { token: string; platform: string },
  ) {
    return this.usersService.registerFcmToken(
      userId,
      body.token,
      body.platform,
    );
  }

  @Delete(':id/fcmToken')
  @ApiOperation({ summary: 'Unregister FCM token' })
  async unregisterFcmToken(
    @Param('id') userId: string,
    @Body() body: { token: string },
  ) {
    await this.usersService.unregisterFcmToken(userId, body.token);
    return { success: true };
  }

  @Get(':id/fcmTokens')
  @ApiOperation({ summary: 'Get user FCM tokens' })
  async getUserFcmTokens(@Param('id') userId: string) {
    return this.usersService.getUserFcmTokens(userId);
  }
}

