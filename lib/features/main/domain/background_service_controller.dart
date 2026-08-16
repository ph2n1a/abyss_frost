import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/background_process.dart';
import 'package:abyss_frost/core/services/live_ping_state.dart';
import 'package:abyss_frost/core/services/notifications_service.dart';
import 'package:abyss_frost/core/court/court.dart';

class PingServiceController {
  final AppDatabase _db;
  final ValueNotifier<bool> isRunning = ValueNotifier(false);
  final ValueNotifier<LivePingState> liveState = ValueNotifier(
    LivePingState(phase: LivePingPhase.serviceStopped),
  );
  Map<String, String> _urlTagMap = {};

  late final NotificationsService notifications;
  late final Court court;

  late final DataCallback _taskDataCallback = _handleTaskData;
  bool _isTaskDataCallbackAttached = false;

  PingServiceController(this._db) {
    notifications = NotificationsService();
    court = Court(liveState);
  }

  Future<void> initialize() async {
    FlutterForegroundTask.initCommunicationPort();

    if (!_isTaskDataCallbackAttached) {
      FlutterForegroundTask.addTaskDataCallback(_taskDataCallback);
      _isTaskDataCallbackAttached = true;
    }

    print('[PING-UI] initialize is start');

    await notifications.initialize();

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'ping_monitor_channel',
        channelName: 'Network monitoring',
        channelDescription: 'Checking website availability in the background',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(60000),
      ),
    );

    final isAlreadyRunning = await FlutterForegroundTask.isRunningService;
    if (isAlreadyRunning) {
      isRunning.value = true;
      print('[PING-UI] The service was already running.');
    }

    final notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    }
  }

  void _handleTaskData(Object data) {
    if (data is! Map) return;
    final event = data['event'];

    switch (event) {
      case 'service_started':
        liveState.value = LivePingState(phase: LivePingPhase.idle);
        break;

      case 'service_stopped':
        liveState.value = LivePingState(phase: LivePingPhase.serviceStopped);
        break;

      case 'cycle_started':
        final urls = (data['urls'] as List?)?.cast<String>() ?? [];

        final rawTagMap = data['urlTagMap'] as Map?;
        final urlTagMap = <String, String>{};
        if (rawTagMap != null) {
          rawTagMap.forEach((key, value) {
            if (key is String && value is String) {
              urlTagMap[key] = value;
            }
          });
        }

        _urlTagMap = urlTagMap;

        liveState.value = LivePingState(
          phase: LivePingPhase.pinging,
          results: urls
              .map(
                (u) => LivePingResult(
                  url: u,
                  status: LivePingStatus.pinging,
                  tag: urlTagMap[u],
                ),
              )
              .toList(),
        );
        break;

      case 'url_completed_realtime':
        final r = data['result'] as Map?;
        if (r != null) {
          final url = r['url'] as String;
          final statusCode = r['statusCode'] as int?;
          final latencyMs = r['latencyMs'] as int?;
          final error = r['error'] as String?;
          final redirects = r['redirects'] as int? ?? 0;
          final usedBypass = r['usedBypass'] as bool? ?? false;

          final status = (statusCode != null && error == null)
              ? LivePingStatus.success
              : LivePingStatus.error;

          final details = <String>[];
          details.add('bypass: ${usedBypass ? 'Yes' : 'No (VPN)'}');
          if (redirects > 0) details.add('redirects: $redirects');
          if (error != null && error.isNotEmpty) details.add('error: $error');
          final networkDetailsStr = details.join(' | ');

          final newResult = LivePingResult(
            url: url,
            status: status,
            statusCode: statusCode,
            latencyMs: latencyMs,
            error: error,
            networkDetails: networkDetailsStr,
            tag: _urlTagMap[url],
          );

          final current = List<LivePingResult>.from(liveState.value.results);
          final idx = current.indexWhere((x) => x.url == newResult.url);
          if (idx >= 0) {
            current[idx] = newResult;
          } else {
            current.add(newResult);
          }
          liveState.value = liveState.value.copyWith(results: current);
        }
        break;

      case 'url_completed':
        final r = data['result'] as Map?;
        if (r != null) {
          final newResult = LivePingResult.fromMap(
            Map<String, dynamic>.from(r),
          );
          final current = List<LivePingResult>.from(liveState.value.results);
          final idx = current.indexWhere((x) => x.url == newResult.url);
          if (idx >= 0) current[idx] = newResult;
          liveState.value = liveState.value.copyWith(results: current);
        }
        break;

      case 'countdown':
        liveState.value = liveState.value.copyWith(
          phase: LivePingPhase.countdown,
          secondsToNext: data['seconds'] as int? ?? 0,
        );
        break;

      case pingLogInsertedEvent:
        _db.notifyUpdates({
          TableUpdate.onTable(_db.pingLogs, kind: UpdateKind.insert),
        });
        break;

      case pingSkippedWiFiEvent:
        final reason = data['reason'] ?? 'unknown';
        print('[PING-UI] Ping skipped WiFi, reason: $reason');
        break;

      case pingSkippedVpnBypassFailedEvent:
        print('[PING-UI] Ping skipped because VPN bypass failed.');
        break;

      case pingSkippedVpnIgnoreEvent:
        final reason = data['reason'] ?? 'unknown';
        print(
          '[PING-UI] Ping skipped because VPN is active (ignore mode), reason: $reason',
        );
        break;
    }
  }

  Future<void> toggle() async {
    final isCurrentlyRunning = await FlutterForegroundTask.isRunningService;
    if (isCurrentlyRunning) {
      await FlutterForegroundTask.stopService();
      isRunning.value = false;
      liveState.value = LivePingState(phase: LivePingPhase.serviceStopped);
      print('[PING-UI] The service has been stopped by the user.');
    } else {
      final hasPermission =
          await FlutterForegroundTask.checkNotificationPermission() ==
          NotificationPermission.granted;
      if (!hasPermission) {
        throw Exception('Allow notifications to work in the background!');
      }

      await FlutterForegroundTask.startService(
        serviceId: 256,
        notificationIcon: const NotificationIcon(
          metaDataName: 'com.abyss_frost.service.NOTIFICATION_ICON',
        ),
        notificationTitle: 'Network monitoring is active',
        notificationText: 'Checking website accessibility',
        callback: startCallback,
      );
      isRunning.value = true;
      print('[PING-UI] The service was launched by the user');
    }
  }

  void dispose() {
    if (_isTaskDataCallbackAttached) {
      FlutterForegroundTask.removeTaskDataCallback(_taskDataCallback);
    }
    court.dispose();
    isRunning.dispose();
    liveState.dispose();
  }
}
