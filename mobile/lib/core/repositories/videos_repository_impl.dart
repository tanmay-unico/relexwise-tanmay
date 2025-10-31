import '../data/videos/videos_local_data_source.dart';
import '../data/videos/videos_remote_data_source.dart';
import 'videos_repository.dart';

class VideosRepositoryImpl implements VideosRepository {
  final VideosRemoteDataSource remote;
  final VideosLocalDataSource local;

  VideosRepositoryImpl({required this.remote, required this.local});

  @override
  Future<List<dynamic>> getLatestVideos({String? channelId, bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await local.getCachedLatestVideos();
      if (cached.isNotEmpty) return cached;
    }
    final fresh = await remote.fetchLatestVideos(channelId: channelId);
    await local.cacheLatestVideos(fresh);
    return fresh;
  }
}


