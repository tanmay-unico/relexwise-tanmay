import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { Video } from './entities/video.entity';
import { Progress } from './entities/progress.entity';
import { Favorite } from './entities/favorite.entity';
import axios from 'axios';

@Injectable()
export class VideosService {
  private readonly logger = new Logger(VideosService.name);

  constructor(
    @InjectRepository(Video)
    private videoRepository: Repository<Video>,
    @InjectRepository(Progress)
    private progressRepository: Repository<Progress>,
    @InjectRepository(Favorite)
    private favoriteRepository: Repository<Favorite>,
    private configService: ConfigService,
  ) {}

  async getLatestVideos(channelId?: string): Promise<Video[]> {
    const targetChannelId = channelId || this.configService.get('YOUTUBE_CHANNEL_ID');
    
    // Check cached videos
    const cachedVideos = await this.videoRepository.find({
      where: { channelId: targetChannelId },
      order: { publishedAt: 'DESC' },
      take: 10,
    });

    // If cache is valid, return it
    if (
      cachedVideos.length > 0 &&
      cachedVideos[0].cacheExpiry &&
      cachedVideos[0].cacheExpiry > new Date()
    ) {
      return cachedVideos;
    }

    // Fetch from YouTube API
    const videos = await this.fetchVideosFromYouTube(targetChannelId);
    
    // Save or update videos
    for (const videoData of videos) {
      await this.videoRepository.save(videoData);
    }

    return videos;
  }

  private async fetchVideosFromYouTube(channelId: string): Promise<Video[]> {
    try {
      const apiKey = this.configService.get('YOUTUBE_API_KEY');
      
      // First, get uploads playlist ID from channel
      const channelResponse = await axios.get(
        'https://www.googleapis.com/youtube/v3/channels',
        {
          params: {
            part: 'contentDetails',
            id: channelId,
            key: apiKey,
          },
        },
      );

      const uploadsPlaylistId =
        channelResponse.data.items[0]?.contentDetails?.relatedPlaylists?.uploads;
      
      if (!uploadsPlaylistId) {
        this.logger.error('Uploads playlist not found for channel');
        return [];
      }

      // Fetch latest videos from uploads playlist
      const videosResponse = await axios.get(
        'https://www.googleapis.com/youtube/v3/playlistItems',
        {
          params: {
            part: 'snippet,contentDetails',
            playlistId: uploadsPlaylistId,
            maxResults: 10,
            key: apiKey,
          },
        },
      );

      const videoIds = videosResponse.data.items.map(
        (item) => item.contentDetails.videoId,
      );

      // Fetch video details
      const detailsResponse = await axios.get(
        'https://www.googleapis.com/youtube/v3/videos',
        {
          params: {
            part: 'snippet,contentDetails',
            id: videoIds.join(','),
            key: apiKey,
          },
        },
      );

      const videos = detailsResponse.data.items.map((item) => {
        const duration = this.parseDuration(item.contentDetails.duration);
        const cacheExpiry = new Date();
        const ttlMinutes = this.configService.get('YT_CACHE_TTL_MIN') || 10;
        cacheExpiry.setMinutes(cacheExpiry.getMinutes() + parseInt(ttlMinutes));

        return {
          videoId: item.id,
          title: item.snippet.title,
          description: item.snippet.description,
          thumbnailUrl: item.snippet.thumbnails.medium.url,
          channelId: item.snippet.channelId,
          channelName: item.snippet.channelTitle,
          publishedAt: new Date(item.snippet.publishedAt),
          durationSeconds: duration,
          cacheExpiry,
        };
      });

      return videos;
    } catch (error) {
      this.logger.error('Error fetching videos from YouTube', error);
      throw error;
    }
  }

  private parseDuration(duration: string): number {
    // Parse ISO 8601 duration (e.g., PT1H2M10S)
    const match = duration.match(/PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/);
    if (!match) return 0;

    const hours = parseInt(match[1] || '0', 10);
    const minutes = parseInt(match[2] || '0', 10);
    const seconds = parseInt(match[3] || '0', 10);

    return hours * 3600 + minutes * 60 + seconds;
  }

  async getVideoById(videoId: string): Promise<Video | null> {
    return this.videoRepository.findOne({ where: { videoId } });
  }

  async updateProgress(
    userId: string,
    videoId: string,
    positionSeconds: number,
    completedPercent: number,
  ): Promise<Progress> {
    let progress = await this.progressRepository.findOne({
      where: { userId, videoId },
    });

    if (progress) {
      progress.positionSeconds = positionSeconds;
      progress.completedPercent = completedPercent;
      progress.synced = true;
    } else {
      progress = this.progressRepository.create({
        userId,
        videoId,
        positionSeconds,
        completedPercent,
        synced: true,
      });
    }

    return this.progressRepository.save(progress);
  }

  async toggleFavorite(userId: string, videoId: string): Promise<boolean> {
    const favorite = await this.favoriteRepository.findOne({
      where: { userId, videoId },
    });

    if (favorite) {
      await this.favoriteRepository.remove(favorite);
      return false;
    } else {
      await this.favoriteRepository.save({
        userId,
        videoId,
        synced: true,
      });
      return true;
    }
  }

  async getUserProgress(userId: string): Promise<Progress[]> {
    return this.progressRepository.find({
      where: { userId },
      relations: ['video'],
    });
  }

  async getUserFavorites(userId: string): Promise<Favorite[]> {
    return this.favoriteRepository.find({
      where: { userId },
      relations: ['video'],
    });
  }
}

