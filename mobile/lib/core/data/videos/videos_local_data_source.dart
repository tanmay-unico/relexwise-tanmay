import '../../storage/videos_cache_store.dart';

abstract class VideosLocalDataSource {
  Future<List<dynamic>> getCachedLatestVideos();
  Future<void> cacheLatestVideos(List<dynamic> videos);
}

class VideosLocalDataSourceImpl implements VideosLocalDataSource {
  @override
  Future<void> cacheLatestVideos(List<dynamic> videos) async {
    await VideosCacheStore.saveLatest(videos);
  }

  @override
  Future<List<dynamic>> getCachedLatestVideos() async {
    return VideosCacheStore.getLatest();
  }
}


