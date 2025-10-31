import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:retrofit/retrofit.dart';
import '../models/user.dart';
import '../models/video.dart';
import '../models/notification.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // Auth
  @POST('/auth/register')
  Future<Map<String, dynamic>> register(@Body() Map<String, dynamic> data);

  @POST('/auth/login')
  Future<Map<String, dynamic>> login(@Body() Map<String, dynamic> data);

  // Videos
  @GET('/videos/latest')
  Future<List<Video>> getLatestVideos(@Query('channelId') String? channelId);

  @GET('/videos/{videoId}')
  Future<Video> getVideoById(@Path('videoId') String videoId);

  @POST('/videos/progress')
  Future<void> updateProgress(@Body() Map<String, dynamic> data);

  @POST('/videos/favorite')
  Future<Map<String, dynamic>> toggleFavorite(@Body() Map<String, dynamic> data);

  // Users
  @POST('/users/{userId}/fcmToken')
  Future<void> registerFcmToken(
    @Path('userId') String userId,
    @Body() Map<String, dynamic> data,
  );

  // Notifications
  @GET('/notifications')
  Future<List<AppNotification>> getNotifications(
    @Query('limit') int? limit,
    @Query('since') String? since,
  );

  @POST('/notifications/send-test')
  Future<AppNotification> sendTestNotification(@Body() Map<String, dynamic> data);

  @POST('/notifications/mark-read')
  Future<void> markAsRead(@Body() Map<String, dynamic> data);

  @DELETE('/notifications/{notificationId}')
  Future<void> deleteNotification(@Path('notificationId') String notificationId);
}

