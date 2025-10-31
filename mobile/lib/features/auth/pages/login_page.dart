import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/api/services.dart';
import '../../../core/api/error_mapper.dart';
import '../../../core/ui/error_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await apiService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final prefs = await SharedPreferences.getInstance();
      final accessToken = res['accessToken'] as String?;
      final user = (res['user'] as Map?) ?? {};
      final userId = user['id'] as String?;

      if (accessToken == null || userId == null) {
        throw 'Invalid login response';
      }

      await prefs.setString('access_token', accessToken);
      await prefs.setString('user_id', userId);
      if (user['name'] is String) {
        await prefs.setString('user_name', user['name'] as String);
      }
      if (user['email'] is String) {
        await prefs.setString('user_email', user['email'] as String);
      }
      await prefs.setBool('is_logged_in', true);
      // ignore: avoid_print
      print('JWT access token len=${accessToken.length} head=${accessToken.substring(0, 12)}...');

      // Try to register FCM token (optional)
      try {
        final fcm = FirebaseMessaging.instance;
        final token = await fcm.getToken();
        if (token != null) {
          await apiService.registerFcmToken(userId, token, 'android');
          // ignore: avoid_print
          print('Registered FCM token len=${token.length} head=${token.substring(0,8)}...');
        }
      } catch (_) {}
      
      if (!mounted) return;
      
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      await showErrorDialog(context, mapErrorToMessage(e));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.play_circle_outline, size: 80, color: Colors.blue),
                  const SizedBox(height: 32),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.register);
                    },
                    child: const Text('Don\'t have an account? Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

