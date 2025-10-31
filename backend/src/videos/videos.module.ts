import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { VideosService } from './videos.service';
import { VideosController } from './videos.controller';
import { Video } from './entities/video.entity';
import { Progress } from './entities/progress.entity';
import { Favorite } from './entities/favorite.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Video, Progress, Favorite])],
  controllers: [VideosController],
  providers: [VideosService],
  exports: [VideosService],
})
export class VideosModule {}

