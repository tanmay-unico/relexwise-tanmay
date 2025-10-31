import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { SendTestNotificationDto } from './dto/send-test-notification.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('notifications')
@Controller('notifications')
export class NotificationsController {
  constructor(private notificationsService: NotificationsService) {}

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get user notifications' })
  async getUserNotifications(
    @Request() req: any,
    @Query('limit') limit?: any,
    @Query('since') since?: string,
  ) {
    const safeLimit = Number.isFinite(Number(limit)) && Number(limit) > 0 ? Number(limit) : 50;
    return this.notificationsService.getUserNotifications(req.user.id, safeLimit, since);
  }

  @Post('send-test')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Send test push notification to own device' })
  async sendTestNotification(
    @Request() req: any,
    @Body() dto: SendTestNotificationDto,
  ) {
    return this.notificationsService.sendTestNotification(
      req.user.id,
      dto.title,
      dto.body,
      dto.idempotencyKey,
    );
  }

  @Post('mark-read')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Mark notifications as read' })
  async markAsRead(
    @Request() req: any,
    @Body() body: { notificationIds: string[] },
  ) {
    await this.notificationsService.markAsRead(
      req.user.id,
      body.notificationIds,
    );
    return { success: true };
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete notification' })
  async deleteNotification(
    @Request() req: any,
    @Param('id') id: string,
  ) {
    await this.notificationsService.deleteNotification(req.user.id, id);
    return { success: true };
  }
}

