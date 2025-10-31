abstract class VideosRepository {
  Future<List<dynamic>> getLatestVideos({String? channelId, bool forceRefresh = false});
}


