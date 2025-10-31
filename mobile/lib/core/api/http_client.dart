import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HttpClient {
  HttpClient._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.resolveBaseUrl(),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          // ignore: avoid_print
          print('[AUTH] attaching bearer token len=${token.length} head=${token.substring(0, 12)}...');
        }
        // verbose request log (no sensitive data)
        // ignore: avoid_print
        print('[HTTP] --> ${options.method} ${options.uri}');
        // ignore: avoid_print
        print('[HTTP] headers: ${Map.from(options.headers)..remove('Authorization')}');
        // ignore: avoid_print
        print('[HTTP] body keys: ${(options.data is Map) ? (options.data as Map).keys.toList() : options.data.runtimeType}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        // ignore: avoid_print
        print('[HTTP] <-- ${response.statusCode} ${response.requestOptions.uri}');
        handler.next(response);
      },
      onError: (e, handler) {
        // ignore: avoid_print
        print('[HTTP] ERR ${e.response?.statusCode} ${e.requestOptions.uri} ${e.message}');
        handler.next(e);
      },
    ));

  static Dio get dio => _dio;
}


