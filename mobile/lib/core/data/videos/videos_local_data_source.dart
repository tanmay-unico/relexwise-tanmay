// Placeholder for local caching (e.g., Drift/SharedPreferences)
// For now, this returns empty and can be expanded later.

abstract class VideosLocalDataSource {
  Future<List<dynamic>> getCachedLatestVideos();
  Future<void> cacheLatestVideos(List<dynamic> videos);
}

class VideosLocalDataSourceImpl implements VideosLocalDataSource {
  List<dynamic> _cache = const [];

  @override
  Future<void> cacheLatestVideos(List<dynamic> videos) async {
    _cache = List<dynamic>.from(videos);
  }

  @override
  Future<List<dynamic>> getCachedLatestVideos() async {
    return _cache;
  }
}


