import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { Inject } from '@nestjs/common';
import * as admin from 'firebase-admin';
import { NotificationsService } from './notifications.service';
import { NotificationJobStatus } from './entities/notification-job.entity';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class NotificationWorkerService {
  private readonly logger = new Logger(NotificationWorkerService.name);
  private isProcessing = false;

  constructor(
    @Inject('FIREBASE_APP') private firebaseApp: admin.app.App,
    private notificationsService: NotificationsService,
    private configService: ConfigService,
  ) {}

  @Cron(CronExpression.EVERY_10_SECONDS)
  async processNotificationJobs() {
    if (this.isProcessing) {
      return;
    }

    const enabled = this.configService.get('NOTIFICATION_WORKER_ENABLED');
    if (enabled === 'false') {
      return;
    }

    this.isProcessing = true;

    try {
      const pendingJobs = await this.notificationsService.getPendingJobs();

      for (const job of pendingJobs) {
        await this.processJob(job);
      }
    } catch (error) {
      this.logger.error('Error processing notification jobs', error);
    } finally {
      this.isProcessing = false;
    }
  }

  private async processJob(job: any) {
    try {
      // Mark as processing
      await this.notificationsService.updateJobStatus(
        job.id,
        NotificationJobStatus.PROCESSING,
      );

      this.logger.log(`Processing notification job ${job.id}`);

      // Send notifications to all tokens
      const results = await this.sendNotificationBatch(job.fcmTokens, {
        title: 'Test Notification',
        body: 'This is a test notification',
        notificationId: job.notificationId,
        type: 'test',
      });

      // Check results
      const failures = results.filter((r) => r.success === false);

      if (failures.length === 0) {
        // All succeeded
        await this.notificationsService.updateJobStatus(
          job.id,
          NotificationJobStatus.SENT,
          'success',
        );
        await this.notificationsService.markNotificationAsSent(
          job.notificationId,
        );
        this.logger.log(`Successfully sent notification job ${job.id}`);
      } else if (failures.length < results.length) {
        // Partial success
        this.logger.warn(
          `Partial success for job ${job.id}: ${results.length - failures.length}/${results.length} succeeded`,
        );
        await this.notificationsService.updateJobStatus(
          job.id,
          NotificationJobStatus.SENT,
          'partial_success',
        );
      } else {
        // All failed
        const maxRetries = parseInt(
          this.configService.get('NOTIFICATION_MAX_RETRIES') || '5',
          10,
        );

        if (job.retries >= maxRetries) {
          // Move to dead letter queue
          await this.notificationsService.updateJobStatus(
            job.id,
            NotificationJobStatus.DLQ,
            'max_retries_exceeded',
            'Failed after max retries',
          );
          this.logger.error(
            `Job ${job.id} moved to DLQ after ${job.retries} retries`,
          );
        } else {
          // Retry
          await this.notificationsService.updateJobStatus(
            job.id,
            NotificationJobStatus.PENDING,
            null,
            `Retry attempt ${job.retries + 1}`,
          );
          this.logger.warn(`Job ${job.id} will be retried`);
        }
      }
    } catch (error) {
      this.logger.error(`Error processing job ${job.id}`, error);
      await this.notificationsService.updateJobStatus(
        job.id,
        NotificationJobStatus.PENDING,
        null,
        error.message,
      );
    }
  }

  private async sendNotificationBatch(
    tokens: string[],
    content: { title: string; body: string; notificationId: string; type: string },
  ): Promise<Array<{ token: string; success: boolean; error?: any }>> {
    const results: Array<{ token: string; success: boolean; error?: any }> = [];

    for (const token of tokens) {
      try {
        await admin.messaging(this.firebaseApp).send({
          token,
          notification: {
            title: content.title,
            body: content.body,
          },
          data: {
            notificationId: content.notificationId,
            type: content.type,
          },
        });

        results.push({ token, success: true });
      } catch (error) {
        results.push({ token, success: false, error });
        this.logger.error(`Failed to send to token ${token}`, error);
      }

      // Small delay to avoid overwhelming FCM
      await new Promise((resolve) => setTimeout(resolve, 100));
    }

    return results;
  }
}

