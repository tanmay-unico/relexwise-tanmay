import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { FcmToken } from './entities/fcm-token.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(FcmToken)
    private fcmTokenRepository: Repository<FcmToken>,
  ) {}

  async create(userData: Partial<User>): Promise<User> {
    const user = this.userRepository.create(userData);
    return this.userRepository.save(user);
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { email } });
  }

  async findById(id: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { id } });
  }

  async registerFcmToken(
    userId: string,
    token: string,
    platform: string,
  ): Promise<FcmToken> {
    // Check if token already exists
    let fcmToken = await this.fcmTokenRepository.findOne({
      where: { token, userId },
    });

    if (!fcmToken) {
      fcmToken = this.fcmTokenRepository.create({
        userId,
        token,
        platform,
      });
      return this.fcmTokenRepository.save(fcmToken);
    }

    // Update platform if changed
    if (fcmToken.platform !== platform) {
      fcmToken.platform = platform;
      return this.fcmTokenRepository.save(fcmToken);
    }

    return fcmToken;
  }

  async unregisterFcmToken(userId: string, token: string): Promise<void> {
    await this.fcmTokenRepository.delete({ userId, token });
  }

  async getUserFcmTokens(userId: string): Promise<FcmToken[]> {
    return this.fcmTokenRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }
}

