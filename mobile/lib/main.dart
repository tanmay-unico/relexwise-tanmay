import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/di/injection.dart' as di;
import 'core/app/app_widget.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize plugin for background isolate
  final plugin = FlutterLocalNotificationsPlugin();
  const channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Channel for foreground notifications',
    importance: Importance.high,
  );
  await plugin.initialize(const InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  ));
  await plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  final n = message.notification;
  final title = n?.title ?? message.data['title'];
  final body = n?.body ?? message.data['body'];
  if (title != null || body != null) {
    await plugin.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'Channel for foreground notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['payload'],
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Channel for foreground notifications',
    importance: Importance.high,
  );
  
  // Initialize Firebase (optional - app works without it)
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // Initialize local notifications
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
    try {
      // Android 13+ notification permission (FCM + local notifications)
      await FirebaseMessaging.instance.requestPermission();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      final token = await FirebaseMessaging.instance.getToken();
      // ignore: avoid_print
      print('FCM token: $token');
      FirebaseMessaging.onMessage.listen((msg) {
        // ignore: avoid_print
        print('FCM onMessage: ${msg.notification?.title ?? msg.data['title']} - ${msg.notification?.body ?? msg.data['body']}');
        final notification = msg.notification;
        final title = notification?.title ?? msg.data['title'];
        final body = notification?.body ?? msg.data['body'];
        if (title != null || body != null) {
          flutterLocalNotificationsPlugin.show(
            msg.hashCode,
            title,
            body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                androidChannel.id,
                androidChannel.name,
                channelDescription: androidChannel.description,
                importance: Importance.high,
                priority: Priority.high,
                icon: notification?.android?.smallIcon,
              ),
              iOS: const DarwinNotificationDetails(),
            ),
            payload: msg.data['payload'],
          );
        }
      });
      // Ensure notification from taps (when app brought to foreground) uses provided title/body
      FirebaseMessaging.onMessageOpenedApp.listen((msg) {
        final notification = msg.notification;
        final title = notification?.title ?? msg.data['title'];
        final body = notification?.body ?? msg.data['body'];
        if (title != null || body != null) {
          flutterLocalNotificationsPlugin.show(
            msg.hashCode,
            title,
            body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                androidChannel.id,
                androidChannel.name,
                channelDescription: androidChannel.description,
                importance: Importance.high,
                priority: Priority.high,
              ),
              iOS: const DarwinNotificationDetails(),
            ),
          );
        }
      });
    } catch (e) {
      // ignore: avoid_print
      print('FCM setup failed: $e');
    }
  } catch (e) {
    print('Firebase initialization failed: $e');
    print('App will continue without Firebase. Add google-services.json to enable Firebase features.');
  }
  
  // Initialize dependency injection
  await di.configureDependencies();
  
  runApp(const AppWidget());
}

