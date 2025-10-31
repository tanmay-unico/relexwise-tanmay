import 'package:flutter/material.dart';
import '../../features/auth/pages/splash_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/home/pages/home_shell_page.dart';
import '../../features/notifications/pages/notifications_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/profile/pages/favorites_page.dart';
import '../../features/video/pages/video_player_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/viewmodels/auth_cubit.dart';
import '../../core/di/injection.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String favorites = '/favorites';
  static const String videoPlayer = '/video-player';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AuthCubit>(),
            child: const LoginPage(),
          ),
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AuthCubit>(),
            child: const RegisterPage(),
          ),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const HomeShellPage());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesPage());
      case videoPlayer:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => VideoPlayerPage(
            videoId: args['videoId'],
            videoTitle: args['videoTitle'],
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

