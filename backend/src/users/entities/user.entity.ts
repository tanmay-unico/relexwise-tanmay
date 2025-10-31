import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  OneToMany,
} from 'typeorm';
import { Progress } from '../../videos/entities/progress.entity';
import { Favorite } from '../../videos/entities/favorite.entity';
import { FcmToken } from './fcm-token.entity';
import { Notification } from '../../notifications/entities/notification.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column()
  name: string;

  @Column()
  passwordHash: string;

  @Column({ default: 'user' })
  role: string;

  @CreateDateColumn()
  createdAt: Date;

  @OneToMany(() => Progress, (progress) => progress.user)
  progress: Progress[];

  @OneToMany(() => Favorite, (favorite) => favorite.user)
  favorites: Favorite[];

  @OneToMany(() => FcmToken, (token) => token.user)
  fcmTokens: FcmToken[];

  @OneToMany(() => Notification, (notification) => notification.user)
  notifications: Notification[];
}

