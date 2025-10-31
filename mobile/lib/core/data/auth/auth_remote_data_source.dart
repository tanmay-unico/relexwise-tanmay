import 'package:firebase_messaging/firebase_messaging.dart';
import '../../api/services.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(String name, String email, String password);
  Future<void> registerFcmToken(String userId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<Map<String, dynamic>> login(String email, String password) {
    return apiService.login(email, password);
  }

  @override
  Future<Map<String, dynamic>> register(String name, String email, String password) {
    return apiService.register(name, email, password);
  }

  @override
  Future<void> registerFcmToken(String userId) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await apiService.registerFcmToken(userId, token, 'android');
    }
  }
}


