import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  CreateDateColumn,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';

@Entity('fcm_tokens')
export class FcmToken {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @ManyToOne(() => User, (user) => user.fcmTokens)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  token: string;

  @Column()
  platform: string; // 'android' | 'ios' | 'web'

  @CreateDateColumn()
  createdAt: Date;
}

