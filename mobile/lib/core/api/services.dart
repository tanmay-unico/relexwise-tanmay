import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'http_client.dart';

class ApiService {
  final Dio _dio = HttpClient.dio;

  // Auth
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final res = await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  // Users
  Future<void> registerFcmToken(String userId, String token, String platform) async {
    await _dio.post('/users/$userId/fcmToken', data: {
      'token': token,
      'platform': platform,
    });
  }

  // Videos
  Future<List<dynamic>> getLatestVideos({String? channelId}) async {
    final res = await _dio.get('/videos/latest', queryParameters: {
      if (channelId != null) 'channelId': channelId,
    });
    return (res.data as List).cast<dynamic>();
  }

  Future<void> updateProgress({
    required String videoId,
    required int positionSeconds,
    required double completedPercent,
  }) async {
    await _dio.post('/videos/progress', data: {
      'videoId': videoId,
      'positionSeconds': positionSeconds,
      'completedPercent': completedPercent,
    });
  }

  Future<Map<String, dynamic>> toggleFavorite(String videoId) async {
    final res = await _dio.post('/videos/favorite', data: {
      'videoId': videoId,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  // Notifications
  Future<List<dynamic>> getNotifications({int? limit, String? since}) async {
    final res = await _dio.get('/notifications', queryParameters: {
      if (limit != null) 'limit': limit,
      if (since != null) 'since': since,
    });
    return (res.data as List).cast<dynamic>();
  }

  Future<void> markRead(List<String> ids) async {
    await _dio.post('/notifications/mark-read', data: {
      'notificationIds': ids,
    });
  }

  Future<void> deleteNotification(String id) async {
    await _dio.delete('/notifications/$id');
  }

  Future<Map<String, dynamic>> sendTestPush(String title, String body) async {
    final res = await _dio.post('/notifications/send-test', data: {
      'title': title,
      'body': body,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }
}

final apiService = ApiService();


