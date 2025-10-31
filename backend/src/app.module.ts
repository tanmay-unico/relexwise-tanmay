import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ScheduleModule } from '@nestjs/schedule';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { VideosModule } from './videos/videos.module';
import { NotificationsModule } from './notifications/notifications.module';
import { NotificationWorkerModule } from './notifications/notification-worker.module';
import { DatabaseConfig } from './config/database.config';
import { FirebaseModule } from './config/firebase.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useClass: DatabaseConfig,
    }),
    ScheduleModule.forRoot(),
    FirebaseModule.forRoot(),
    AuthModule,
    UsersModule,
    VideosModule,
    NotificationsModule,
    NotificationWorkerModule,
  ],
})
export class AppModule {}

