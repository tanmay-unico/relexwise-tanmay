import { Module } from '@nestjs/common';
import { NotificationWorkerService } from './notification-worker.service';
import { NotificationsModule } from './notifications.module';

@Module({
  imports: [NotificationsModule],
  providers: [NotificationWorkerService],
})
export class NotificationWorkerModule {}

