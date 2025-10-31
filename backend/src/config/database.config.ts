import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { TypeOrmModuleOptions, TypeOrmOptionsFactory } from '@nestjs/typeorm';
import { User } from '../users/entities/user.entity';
import { Video } from '../videos/entities/video.entity';
import { Progress } from '../videos/entities/progress.entity';
import { Favorite } from '../videos/entities/favorite.entity';
import { FcmToken } from '../users/entities/fcm-token.entity';
import { Notification } from '../notifications/entities/notification.entity';
import { NotificationJob } from '../notifications/entities/notification-job.entity';
import { PendingAction } from '../common/entities/pending-action.entity';

@Injectable()
export class DatabaseConfig implements TypeOrmOptionsFactory {
  constructor(private configService: ConfigService) {}

  createTypeOrmOptions(): TypeOrmModuleOptions {
    const host = this.configService.get<string>('DB_HOST');
    const shouldUseSslEnv = this.configService.get<string>('DB_SSL');
    const shouldUseSsl =
      (shouldUseSslEnv && shouldUseSslEnv.toString().toLowerCase() === 'true') ||
      (host && host !== 'localhost' && host !== '127.0.0.1');

    return {
      type: 'postgres',
      host,
      port: this.configService.get('DB_PORT'),
      username: this.configService.get('DB_USERNAME'),
      password: this.configService.get('DB_PASSWORD'),
      database: this.configService.get('DB_NAME'),
      ssl: shouldUseSsl
        ? {
            rejectUnauthorized: false,
          }
        : undefined,
      entities: [
        User,
        Video,
        Progress,
        Favorite,
        FcmToken,
        Notification,
        NotificationJob,
        PendingAction,
      ],
      synchronize: this.configService.get('NODE_ENV') === 'development',
      logging: this.configService.get('NODE_ENV') === 'development',
    };
  }
}

