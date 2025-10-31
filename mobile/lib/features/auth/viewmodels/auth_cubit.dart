import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/repositories/auth_repository.dart';

sealed class AuthState {}
class AuthIdle extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {}
class AuthError extends AuthState { final String message; AuthError(this.message); }

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  AuthCubit(this.repository) : super(AuthIdle());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final res = await repository.login(email, password);
      await _persistAuth(res);
      emit(AuthSuccess());
    } catch (_) {
      emit(AuthError('Incorrect email or password. Please try again.'));
    }
  }

  Future<void> register(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final res = await repository.register(name, email, password);
      await _persistAuth(res);
      emit(AuthSuccess());
    } catch (_) {
      emit(AuthError('Registration failed. Please try again.'));
    }
  }

  Future<void> _persistAuth(Map<String, dynamic> res) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = res['accessToken'] as String?;
    final user = (res['user'] as Map?) ?? {};
    final userId = user['id'] as String?;
    if (accessToken == null || userId == null) {
      throw Exception('Invalid auth response');
    }
    await prefs.setString('access_token', accessToken);
    await prefs.setString('user_id', userId);
    if (user['name'] is String) await prefs.setString('user_name', user['name'] as String);
    if (user['email'] is String) await prefs.setString('user_email', user['email'] as String);
    await prefs.setBool('is_logged_in', true);
    await repository.registerFcmToken(userId);
  }
}


