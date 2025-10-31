import {
  Injectable,
  Logger,
  ConflictException,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import { Notification } from './entities/notification.entity';
import { NotificationJob, NotificationJobStatus } from './entities/notification-job.entity';
import { UsersService } from '../users/users.service';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);
  
  // In-memory rate limit tracking (for production, use Redis)
  private rateLimitMap = new Map<string, { count: number; resetAt: Date }>();

  constructor(
    @InjectRepository(Notification)
    private notificationRepository: Repository<Notification>,
    @InjectRepository(NotificationJob)
    private notificationJobRepository: Repository<NotificationJob>,
    private usersService: UsersService,
  ) {}

  async getUserNotifications(
    userId: string,
    limit: number = 50,
    since?: string,
  ): Promise<Notification[]> {
    const safeLimit = Number.isFinite(Number(limit)) && Number(limit) > 0 ? Number(limit) : 50;
    this.logger.debug(`getUserNotifications userId=${userId} limit=${safeLimit} since=${since}`);
    const query = this.notificationRepository.createQueryBuilder('notification')
      .where('notification.userId = :userId', { userId })
      .andWhere('notification.isDeleted = :deleted', { deleted: false })
      .orderBy('notification.createdAt', 'DESC')
      .limit(safeLimit);

    if (since) {
      query.andWhere('notification.createdAt > :since', {
        since: new Date(since),
      });
    }

    return query.getMany();
  }

  async markAsRead(
    userId: string,
    notificationIds: string[],
  ): Promise<void> {
    await this.notificationRepository.update(
      { id: { $in: notificationIds } as any, userId },
      { isRead: true },
    );
  }

  async deleteNotification(
    userId: string,
    notificationId: string,
  ): Promise<void> {
    await this.notificationRepository.update(
      { id: notificationId, userId },
      { isDeleted: true },
    );
  }

  async sendTestNotification(
    userId: string,
    title: string,
    body: string,
    idempotencyKey?: string,
  ): Promise<Notification> {
    this.logger.debug(`sendTestNotification userId=${userId} titleLen=${title?.length} bodyLen=${body?.length} idempotencyKey=${idempotencyKey}`);
    // Check rate limit
    this.checkRateLimit(userId);

    // Check idempotency
    if (idempotencyKey) {
      const existing = await this.notificationRepository.findOne({
        where: { userId, metadata: { idempotencyKey } } as any,
      });
      if (existing) {
        return existing;
      }
    }

    // Create notification
    const notification = this.notificationRepository.create({
      userId,
      title,
      body,
      metadata: idempotencyKey ? { idempotencyKey } : null,
      sent: false,
    });

    const savedNotification = await this.notificationRepository.save(notification);

    // Get user's FCM tokens
    const fcmTokens = await this.usersService.getUserFcmTokens(userId);
    const tokenList = fcmTokens.map((t) => t.token);
    this.logger.debug(`FCM tokens found: count=${tokenList.length}`);

    if (tokenList.length > 0) {
      // Create notification job
      const job = this.notificationJobRepository.create({
        notificationId: savedNotification.id,
        userId,
        fcmTokens: tokenList,
        status: NotificationJobStatus.PENDING,
      });

      await this.notificationJobRepository.save(job);
      this.logger.log(`Created notification job ${job.id} for user ${userId}`);
    }

    return savedNotification;
  }

  private checkRateLimit(userId: string): void {
    const limit = parseInt(process.env.TEST_PUSH_RATE_LIMIT || '5', 10);
    const windowMs = parseInt(process.env.TEST_PUSH_WINDOW_MS || '60000', 10);

    const now = new Date();
    const userLimit = this.rateLimitMap.get(userId);

    if (userLimit) {
      if (userLimit.resetAt <= now) {
        // Reset window
        this.rateLimitMap.set(userId, { count: 1, resetAt: new Date(now.getTime() + windowMs) });
      } else if (userLimit.count >= limit) {
        throw new HttpException(
          `Rate limit exceeded. Max ${limit} requests per minute.`,
          HttpStatus.TOO_MANY_REQUESTS,
        );
      } else {
        userLimit.count++;
      }
    } else {
      this.rateLimitMap.set(userId, { count: 1, resetAt: new Date(now.getTime() + windowMs) });
    }
  }

  async getPendingJobs(): Promise<NotificationJob[]> {
    return this.notificationJobRepository.find({
      where: { status: NotificationJobStatus.PENDING },
      order: { createdAt: 'ASC' },
      take: 10,
    });
  }

  async updateJobStatus(
    jobId: string,
    status: NotificationJobStatus,
    messageId?: string,
    error?: string,
  ): Promise<void> {
    const updateData: any = {
      status,
      retries: () => 'retries + 1',
      processingAt: new Date(),
    };

    if (messageId) {
      updateData.messageId = messageId;
    }

    if (error) {
      updateData.lastError = error;
    }

    await this.notificationJobRepository.update({ id: jobId }, updateData);
  }

  async markNotificationAsSent(notificationId: string): Promise<void> {
    await this.notificationRepository.update(
      { id: notificationId },
      { sent: true },
    );
  }

  async getDeadLetterJobs(): Promise<NotificationJob[]> {
    return this.notificationJobRepository.find({
      where: { status: NotificationJobStatus.DLQ },
      order: { createdAt: 'DESC' },
      take: 20,
    });
  }
}

