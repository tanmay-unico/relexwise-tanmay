import '../data/auth/auth_remote_data_source.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl({required this.remote});

  @override
  Future<Map<String, dynamic>> login(String email, String password) {
    return remote.login(email, password);
  }

  @override
  Future<Map<String, dynamic>> register(String name, String email, String password) {
    return remote.register(name, email, password);
  }

  @override
  Future<void> registerFcmToken(String userId) {
    return remote.registerFcmToken(userId);
  }
}


