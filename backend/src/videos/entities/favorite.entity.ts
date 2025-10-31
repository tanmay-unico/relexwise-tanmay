import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  CreateDateColumn,
  JoinColumn,
  Unique,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Video } from './video.entity';

@Entity('favorites')
@Unique(['userId', 'videoId'])
export class Favorite {
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

  @Column({ default: false })
  synced: boolean;

  @CreateDateColumn()
  createdAt: Date;
}

