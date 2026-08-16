import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService {
  static final NotificationsService _instance = NotificationsService._();
  factory NotificationsService() => _instance;
  NotificationsService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize({bool requestPermissions = true}) async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(settings: settings);
    if (requestPermissions && Platform.isAndroid) {
      try {
        final platform = (_plugin as dynamic).resolvePlatform();
        await platform.requestNotificationsPermission();
      } catch (_) {
        try {
          final platform = (_plugin as dynamic).resolvePlatformSpecifier();
          await platform.requestNotificationsPermission();
        } catch (_) {
          try {
            final androidPlugin = AndroidFlutterLocalNotificationsPlugin();
            await androidPlugin.requestNotificationsPermission();
          } catch (e) {
            debugPrint(
              'Could not request notification permission automatically: $e',
            );
          }
        }
      }
    }

    _initialized = true;
  }

  Future<void> showInternetRestoredNotification({
    required Duration offlineDuration,
  }) async {
    // The foreground task runs in a separate isolate, so it has its own
    // instance state and must initialize the plugin there as well.
    await initialize(requestPermissions: false);

    final minutes = offlineDuration.inMinutes;
    final hours = offlineDuration.inHours;

    String durationText;
    if (hours > 0) {
      final remainingMinutes = minutes % 60;
      durationText = '${hours}h ${remainingMinutes}m';
    } else {
      durationText = '${minutes}m';
    }

    const androidDetails = AndroidNotificationDetails(
      'internet_status_channel',
      'Internet Status',
      icon: 'ic_notification',
      channelDescription: 'Notifications about network availability',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: 2001,
      title: 'Internet restored 🎉',
      body: 'Connection was absent for $durationText',
      notificationDetails: details,
    );
  }
}
