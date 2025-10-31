import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum NotificationJobStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  SENT = 'sent',
  FAILED = 'failed',
  DLQ = 'dlq',
}

@Entity('notification_jobs')
export class NotificationJob {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  notificationId: string;

  @Column()
  userId: string;

  @Column('simple-array', { nullable: true })
  fcmTokens: string[];

  @Column({
    type: 'enum',
    enum: NotificationJobStatus,
    default: NotificationJobStatus.PENDING,
  })
  status: NotificationJobStatus;

  @Column({ type: 'int', default: 0 })
  retries: number;

  @Column('text', { nullable: true })
  lastError: string;

  @Column('text', { nullable: true })
  messageId: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  processingAt: Date;
}

