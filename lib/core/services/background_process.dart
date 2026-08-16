import 'dart:async';
import 'dart:ui';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_database.dart';
import 'package:network_prober/network_prober.dart';
import 'package:abyss_frost/core/court/judge.dart';
import 'package:abyss_frost/core/services/live_ping_state.dart';
import 'package:abyss_frost/core/services/notifications_service.dart';

const String _logTag = '[BACKGROUND-PING]';

const String pingLogInsertedEvent = 'ping_log_inserted';
const String pingSkippedWiFiEvent = 'ping_skipped_wifi';
const String pingSkippedVpnBypassFailedEvent = 'ping_skipped_vpn_bypass_failed';
const String pingSkippedVpnIgnoreEvent = 'ping_skipped_vpn_ignore';

const String pingMethodHead = 'Via Proxy HEAD';
const String pingMethodGet = 'Via Proxy GET';

@pragma('vm:entry-point')
void startCallback() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final token = RootIsolateToken.instance;
  if (token != null) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    DartPluginRegistrant.ensureInitialized();
  }
  FlutterForegroundTask.setTaskHandler(PingTaskHandler());
}

class PingTaskHandler extends TaskHandler {
  int _pingCount = 0;
  AppDatabase? _db;
  bool _isRunning = false;

  bool _bypassVPN = false;
  bool _ignoreVPN = true;
  bool _doNotAnalyzeWiFi = true;
  bool _ignoreSslErrors = false;
  String _pingMethod = pingMethodHead;
  List<String> _targetsUrl = [];
  List<String> _targetsUrlTags = [];
  int _intervalSeconds = 60;

  String _proxyHost = '';
  int _proxyPort = 8080;
  bool _useProxy = false;

  StreamSubscription? _pingStreamSub;
  final NotificationsService _notifications = NotificationsService();
  DateTime? _internetDownSince;

  static const List<String> _defaultTargets = [
    'google.com',
    'cloudflare.com',
    'ru.devnetspace.com',
    'github.com',
    'yandex.ru',
    'vk.ru',
    'telegram.org',
    'youtube.com',
  ];
  static const List<String> _defaultTargetTags = [
    'neutral',
    'neutral',
    'neutral',
    'neutral',
    'whitelist',
    'whitelist',
    'blacklist',
    'blacklist',
  ];

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('$_logTag ==========================================');
    print('$_logTag onStart called');
    _isRunning = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await _loadSettings(prefs);
      await _notifications.initialize(requestPermissions: false);
      _db = await getDatabase();
      print(
        '$_logTag Settings: interval=${_intervalSeconds}s, method=$_pingMethod, '
            'bypassVPN=$_bypassVPN, ignoreVPN=$_ignoreVPN, ignoreWiFi=$_doNotAnalyzeWiFi',
      );

      _pingStreamSub = NetworkProber.pingResultsStream.listen(
            (event) {
          if (event is Map) {
            print('$_logTag 📥 Real-time result from Kotlin: ${event['url']}');
            FlutterForegroundTask.sendDataToMain({
              'event': 'url_completed_realtime',
              'result': Map<String, dynamic>.from(event),
            });
          }
        },
        onError: (e) {
          print('$_logTag ❌ Stream error: $e');
        },
      );

      FlutterForegroundTask.sendDataToMain({'event': 'service_started'});
      unawaited(_runMainLoop());
    } catch (e, st) {
      print('$_logTag onStart error: $e\n$st');
      rethrow;
    }
  }

  Future<void> _runMainLoop() async {
    while (_isRunning) {
      try {
        await _executeOneCycle();
      } catch (e, st) {
        print('$_logTag Cycle error: $e\n$st');
      }

      for (int i = _intervalSeconds; i > 0 && _isRunning; i--) {
        FlutterForegroundTask.sendDataToMain({
          'event': 'countdown',
          'seconds': i,
        });
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  Future<void> _executeOneCycle() async {
    _pingCount++;
    print('$_logTag 🔄 ========== CYCLE #$_pingCount ==========');

    await _ensureDatabase();
    if (_db == null) {
      print('$_logTag ❌ Database is null, skipping cycle');
      return;
    }

    final SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
      await _loadSettings(prefs);
    } catch (e) {
      print('$_logTag ❌ Failed to load settings: $e');
      return;
    }

    // 1️⃣ Проверка WiFi
    if (_doNotAnalyzeWiFi) {
      final wifi = await NetworkProber.isWifiConnected();
      print('$_logTag 📶 WiFi check: $wifi');
      if (wifi == true || wifi == null) {
        print('$_logTag ⏭️ Skipping cycle due to WiFi');
        FlutterForegroundTask.sendDataToMain({
          'event': pingSkippedWiFiEvent,
          'reason': wifi == true ? 'wifi_connected' : 'wifi_check_failed',
        });
        return;
      }
    }

    final vpnActive = await NetworkProber.isVpnActive();
    print('$_logTag 🔒 VPN active: $vpnActive');

    if (vpnActive) {
      bool bypassed = false;

      if (_bypassVPN) {
        bypassed = await NetworkProber.bindToPhysicalNetwork();
        print('$_logTag 🔓 VPN bypass result: $bypassed');
        if (!bypassed) {
          print('$_logTag ⚠️ VPN bypass failed');
        }
      }

      if (!bypassed && _ignoreVPN) {
        print('$_logTag ⏭️ Skipping cycle due to VPN (ignoreVPN=true, bypassed=$bypassed)');
        FlutterForegroundTask.sendDataToMain({
          'event': pingSkippedVpnIgnoreEvent,
          'reason': _bypassVPN ? 'bypass_failed' : 'vpn_active',
        });
        return;
      }

      if (_bypassVPN && !bypassed) {
        print('$_logTag ⚠️ Bypass failed, falling back to VPN tunnel');
        FlutterForegroundTask.sendDataToMain({
          'event': pingSkippedVpnBypassFailedEvent,
          'reason': 'fallback_to_vpn',
        });
      }
    }

    final targets = _targetsUrl
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    print('$_logTag 🎯 Targets count: ${targets.length}');
    if (targets.isEmpty) {
      print('$_logTag ❌ No targets, skipping cycle');
      return;
    }

    final urlTagMap = <String, String>{};
    for (final url in targets) {
      final tag = _getTagForUrl(url);
      urlTagMap[url] = tag;
    }

    FlutterForegroundTask.sendDataToMain({
      'event': 'cycle_started',
      'urls': targets,
      'urlTagMap': urlTagMap,
    });

    final probeMethod = _pingMethod == pingMethodGet ? 'GET' : 'HEAD';

    final probeResults = await NetworkProber.probeUrls(
      urls: targets,
      method: probeMethod,
      timeoutMs: 5000,
      proxyHost: _useProxy ? _proxyHost : null,
      proxyPort: _useProxy ? _proxyPort : null,
      acceptInvalidCerts: _ignoreSslErrors,
      maxRedirects: 3,
    );

    print('$_logTag ✅ Probe completed: ${probeResults.length} results');

    // 🔍 ДЕТАЛЬНОЕ ЛОГИРОВАНИЕ РЕЗУЛЬТАТОВ
    for (int i = 0; i < probeResults.length; i++) {
      final r = probeResults[i];
      print('$_logTag 📊 Result ${i + 1}: url=${r.url}, status=${r.statusCode}, error=${r.error}, latency=${r.latencyMs}ms');
    }

    final notificationsEnabled = prefs.getBool('message') ?? false;
    print('$_logTag 🔔 Notifications enabled: $notificationsEnabled (key: "message")');

    // Попробуем альтернативные ключи
    final altKey1 = prefs.getBool('notifications_enabled') ?? false;
    final altKey2 = prefs.getBool('message_notifications') ?? false;
    print('$_logTag 🔔 Alt keys: notifications_enabled=$altKey1, message_notifications=$altKey2');

    await _notifyAboutInternetRestoration(
      probeResults: probeResults,
      urlTagMap: urlTagMap,
      notificationsEnabled: notificationsEnabled,
    );

    for (final r in probeResults) {
      final details = <String>[];
      details.add('bypass used: ${r.usedBypass ? 'Yes' : 'No (VPN)'}');
      if (r.redirects > 0) details.add('redirects: ${r.redirects}');
      if (r.error != null && r.error!.isNotEmpty) {
        details.add('error: ${r.error}');
      }
      final networkDetailsStr = details.join(' | ');

      try {
        await _db!.insertPingLog(
          PingLogsCompanion.insert(
            targetUrl: r.url,
            statusCode: Value(r.statusCode),
            latencyMs: Value(r.latencyMs),
            pingMethod: _pingMethod,
            networkDetails: Value(networkDetailsStr),
          ),
        );
      } catch (e) {
        print('$_logTag ❌ DB insert error: $e');
      }
    }

    FlutterForegroundTask.sendDataToMain({
      'event': 'cycle_completed',
      'count': probeResults.length,
    });
    FlutterForegroundTask.sendDataToMain({
      'event': pingLogInsertedEvent,
      'count': probeResults.length,
    });
  }

  Future<void> _notifyAboutInternetRestoration({
    required List<dynamic> probeResults,
    required Map<String, String> urlTagMap,
    required bool notificationsEnabled,
  }) async {
    print('$_logTag 🔍 === RESTORATION CHECK ===');
    print('$_logTag 🔍 Previous outage started: $_internetDownSince');

    final results = probeResults.map(
          (result) => LivePingResult(
        url: result.url as String,
        status: result.statusCode != null && result.error == null
            ? LivePingStatus.success
            : LivePingStatus.error,
        statusCode: result.statusCode as int?,
        error: result.error as String?,
        tag: urlTagMap[result.url],
      ),
    ).toList();

    print('$_logTag 🔍 Converting ${results.length} results to LivePingResult');
    for (int i = 0; i < results.length; i++) {
      final r = results[i];
      print('$_logTag 🔍 LivePingResult ${i + 1}: url=${r.url}, status=${r.status}, code=${r.statusCode}, error=${r.error}, tag=${r.tag}');
    }

    final verdict = evaluateJudge(results);
    print('$_logTag 🔍 Verdict from evaluateJudge: $verdict');

    if (verdict == Verdict.noInternet || verdict == Verdict.error || verdict == Verdict.waiting) {
      print('$_logTag 🔍 Internet is DOWN (verdict=$verdict)');
      _internetDownSince ??= DateTime.now();
      print('$_logTag 🔍 Outage started at: $_internetDownSince');
      return;
    }

    print('$_logTag 🔍 Internet is UP (verdict=$verdict)');

    final outageStartedAt = _internetDownSince;
    _internetDownSince = null;

    print('$_logTag 🔍 Outage was at: $outageStartedAt');

    if (outageStartedAt == null) {
      print('$_logTag ⚠️ No previous outage recorded, skipping notification');
      return;
    }

    if (!notificationsEnabled) {
      print('$_logTag ⚠️ Notifications disabled, skipping');
      return;
    }

    try {
      final outageDuration = DateTime.now().difference(outageStartedAt);
      print('$_logTag 📢 Showing notification: outage duration ${outageDuration.inSeconds}s');

      await _notifications.showInternetRestoredNotification(
        offlineDuration: outageDuration,
      );
      print('$_logTag ✅ Internet restored notification shown successfully');
    } catch (error, stackTrace) {
      print('$_logTag ❌ Failed to show restoration notification: $error');
      print('$_logTag Stack trace: $stackTrace');
    }
  }

  String _getTagForUrl(String url) {
    final trimmedUrl = url.trim();
    final idx = _targetsUrl.indexWhere((u) => u.trim() == trimmedUrl);
    if (idx >= 0 && idx < _targetsUrlTags.length) {
      return _targetsUrlTags[idx];
    }
    return 'neutral';
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {}

  Future<void> _ensureDatabase() async {
    if (_db != null) return;
    try {
      _db = await getDatabase();
    } catch (_) {
      _db = null;
    }
  }

  Future<void> _loadSettings(SharedPreferences prefs) async {
    _bypassVPN = prefs.getBool('bypass_VPN') ?? false;
    _ignoreVPN = prefs.getBool('ignore_VPN') ?? true;
    _pingMethod = prefs.getString('ping_method') ?? pingMethodHead;
    _doNotAnalyzeWiFi = prefs.getBool('do_not_analyze_wifi') ?? true;
    _ignoreSslErrors = prefs.getBool('ignore_ssl_errors') ?? false;
    _intervalSeconds = prefs.getInt('how_often_ping') ?? 60;

    final urls = prefs.getStringList('targets_URL') ?? [];
    final tags = prefs.getStringList('targets_URL_tags') ?? [];

    _targetsUrl = [];
    _targetsUrlTags = [];
    for (int i = 0; i < urls.length; i++) {
      final url = urls[i].trim();
      if (url.isEmpty) continue;

      _targetsUrl.add(url);
      final tag = i < tags.length ? tags[i].trim() : '';
      _targetsUrlTags.add(tag.isEmpty ? 'neutral' : tag);
    }

    if (_targetsUrl.isEmpty) {
      _targetsUrl = List<String>.from(_defaultTargets);
      _targetsUrlTags = List<String>.from(_defaultTargetTags);
    }

    _proxyHost = (prefs.getString('proxy_host') ?? '').trim();
    _proxyPort = prefs.getInt('proxy_port') ?? 8080;
    _useProxy =
        prefs.getBool('proxy_enabled') ??
            (_proxyHost.isNotEmpty && _proxyPort > 0 && _proxyHost != '127.0.0.1');
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTerminated) async {
    print('$_logTag onDestroy called');
    _isRunning = false;
    _pingStreamSub?.cancel();

    try {
      await NetworkProber.unbindNetwork();
    } catch (_) {}
    try {
      await _db?.close();
    } catch (_) {}

    print('$_logTag Total cycles performed: $_pingCount');
    FlutterForegroundTask.sendDataToMain({'event': 'service_stopped'});
  }

  @override
  void onReceiveData(Object data) {}
}