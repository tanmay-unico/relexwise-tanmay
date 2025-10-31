import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { VideosService } from './videos.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('videos')
@Controller('videos')
export class VideosController {
  constructor(private videosService: VideosService) {}

  @Get('latest')
  @ApiOperation({ summary: 'Get latest videos from YouTube channel' })
  async getLatestVideos(@Query('channelId') channelId?: string) {
    return this.videosService.getLatestVideos(channelId);
  }

  @Get(':videoId')
  @ApiOperation({ summary: 'Get video by ID' })
  async getVideoById(@Param('videoId') videoId: string) {
    return this.videosService.getVideoById(videoId);
  }

  @Post('progress')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update video progress' })
  async updateProgress(
    @Request() req: any,
    @Body()
    body: {
      videoId: string;
      positionSeconds: number;
      completedPercent: number;
    },
  ) {
    return this.videosService.updateProgress(
      req.user.id,
      body.videoId,
      body.positionSeconds,
      body.completedPercent,
    );
  }

  @Post('favorite')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Toggle favorite video' })
  async toggleFavorite(
    @Request() req: any,
    @Body() body: { videoId: string },
  ) {
    const isFavorite = await this.videosService.toggleFavorite(
      req.user.id,
      body.videoId,
    );
    return { isFavorite };
  }

  @Get('user/progress')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get user video progress' })
  async getUserProgress(@Request() req: any) {
    return this.videosService.getUserProgress(req.user.id);
  }

  @Get('user/favorites')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get user favorite videos' })
  async getUserFavorites(@Request() req: any) {
    return this.videosService.getUserFavorites(req.user.id);
  }
}

