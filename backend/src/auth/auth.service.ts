import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  Logger,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async register(registerDto: RegisterDto) {
    const existingUser = await this.usersService.findByEmail(
      registerDto.email,
    );
    if (existingUser) {
      throw new ConflictException('Email already exists');
    }

    const passwordHash = await bcrypt.hash(registerDto.password, 10);
    const user = await this.usersService.create({
      ...registerDto,
      passwordHash,
    });

    const tokens = this.generateTokens(user.id, user.email);
    this.logger.log(`register issued token userId=${user.id} email=${user.email} tokenLen=${tokens.accessToken?.length}`);
    return {
      user: { id: user.id, email: user.email, name: user.name },
      ...tokens,
    };
  }

  async login(loginDto: LoginDto) {
    const user = await this.usersService.findByEmail(loginDto.email);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(
      loginDto.password,
      user.passwordHash,
    );
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const tokens = this.generateTokens(user.id, user.email);
    this.logger.log(`login issued token userId=${user.id} email=${user.email} tokenLen=${tokens.accessToken?.length}`);
    return {
      user: { id: user.id, email: user.email, name: user.name },
      ...tokens,
    };
  }

  private generateTokens(userId: string, email: string) {
    const payload = { sub: userId, email };
    return {
      accessToken: this.jwtService.sign(payload),
    };
  }

  async validateUser(userId: string) {
    return this.usersService.findById(userId);
  }
}

