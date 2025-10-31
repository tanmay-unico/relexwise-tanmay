import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  CreateDateColumn,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  title: string;

  @Column('text')
  body: string;

  @Column('jsonb', { nullable: true })
  metadata: any;

  @Column({ default: false })
  isRead: boolean;

  @Column({ default: false })
  isDeleted: boolean;

  @Column({ default: false })
  sent: boolean;

  @CreateDateColumn()
  receivedAt: Date;

  @CreateDateColumn()
  createdAt: Date;
}

