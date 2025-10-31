import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
} from 'typeorm';

export enum PendingActionType {
  PROGRESS_UPDATE = 'progress_update',
  FAVORITE_TOGGLE = 'favorite_toggle',
  NOTIFICATION_DELETE = 'notification_delete',
}

@Entity('pending_actions')
export class PendingAction {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column({
    type: 'enum',
    enum: PendingActionType,
  })
  actionType: PendingActionType;

  @Column('jsonb')
  payload: any;

  @Column({ default: false })
  synced: boolean;

  @CreateDateColumn()
  createdAt: Date;
}

