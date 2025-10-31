import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  CreateDateColumn,
  UpdateDateColumn,
  JoinColumn,
  Unique,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Video } from './video.entity';

@Entity('progress')
@Unique(['userId', 'videoId'])
export class Progress {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  videoId: string;

  @ManyToOne(() => Video)
  @JoinColumn({ name: 'videoId' })
  video: Video;

  @Column({ type: 'int', default: 0 })
  positionSeconds: number;

  @Column({ type: 'float', default: 0 })
  completedPercent: number;

  @Column({ default: false })
  synced: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

