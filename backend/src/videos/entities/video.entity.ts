import {
  Entity,
  Column,
  PrimaryColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('videos')
export class Video {
  @PrimaryColumn()
  videoId: string;

  @Column()
  title: string;

  @Column('text', { nullable: true })
  description: string;

  @Column()
  thumbnailUrl: string;

  @Column()
  channelId: string;

  @Column({ nullable: true })
  channelName: string;

  @Column()
  publishedAt: Date;

  @Column({ type: 'int', nullable: true })
  durationSeconds: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  cacheExpiry: Date;
}

