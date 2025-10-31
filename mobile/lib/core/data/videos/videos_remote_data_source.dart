import '../../api/services.dart';

abstract class VideosRemoteDataSource {
  Future<List<dynamic>> fetchLatestVideos({String? channelId});
}

class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  @override
  Future<List<dynamic>> fetchLatestVideos({String? channelId}) {
    return apiService.getLatestVideos(channelId: channelId);
  }
}


