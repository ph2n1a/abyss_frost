import 'dart:io';
import 'package:flutter/services.dart';

class ProbeResult {
  final String url;
  final int? statusCode;
  final int latencyMs;
  final String? error;
  final int redirects;
  final bool usedBypass;
  final String? tag;

  ProbeResult({
    required this.url,
    required this.statusCode,
    required this.latencyMs,
    required this.error,
    required this.redirects,
    required this.usedBypass,
    this.tag,
  });

  factory ProbeResult.fromMap(Map<String, dynamic> map) {
    return ProbeResult(
      url: map['url'] as String,
      statusCode: map['statusCode'] as int?,
      latencyMs: (map['latencyMs'] as num?)?.toInt() ?? 0,
      error: map['error'] as String?,
      redirects: (map['redirects'] as num?)?.toInt() ?? 0,
      usedBypass: map['usedBypass'] as bool? ?? false,
      tag: map['tag'] as String?,
    );
  }

  @override
  String toString() {
    return 'ProbeResult(url: $url, tag: $tag, statusCode: $statusCode, '
        'latencyMs: $latencyMs, error: $error, redirects: $redirects, '
        'usedBypass: $usedBypass)';
  }
}

class NetworkProber {
  static const MethodChannel _channel =
  MethodChannel('com.abyss_frost/network_prober');

  static const EventChannel _eventChannel =
  EventChannel('com.abyss_frost/network_prober_events');

  static Stream<dynamic> get pingResultsStream {
    return _eventChannel.receiveBroadcastStream();
  }

  static Future<bool> isVpnActive() async {
    print('[NetworkProber] Calling isVpnActive()');
    if (!Platform.isAndroid) {
      print('[NetworkProber] isVpnActive: Not Android, returning false');
      return false;
    }
    try {
      final result =
          await _channel.invokeMethod<bool>('isVpnActive') ?? false;
      print('[NetworkProber] isVpnActive result: $result');
      return result;
    } catch (e) {
      print('[NetworkProber] isVpnActive error: $e');
      return false;
    }
  }

  static Future<bool?> isWifiConnected() async {
    print('[NetworkProber] Calling isWifiConnected()');
    if (!Platform.isAndroid) {
      print('[NetworkProber] isWifiConnected: Not Android, returning false');
      return false;
    }
    try {
      final result = await _channel.invokeMethod<bool>('isWifiConnected');
      print('[NetworkProber] isWifiConnected result: $result');
      return result;
    } catch (e) {
      print('[NetworkProber] isWifiConnected error: $e');
      return null;
    }
  }

  static Future<bool> bindToPhysicalNetwork() async {
    print('[NetworkProber] Calling bindToPhysicalNetwork()');
    if (!Platform.isAndroid) {
      print('[NetworkProber] bindToPhysicalNetwork: Not Android, returning false');
      return false;
    }
    try {
      final result = await _channel.invokeMethod<bool>('bindToPhysicalNetwork') ?? false;
      print('[NetworkProber] bindToPhysicalNetwork result: $result');
      return result;
    } catch (e) {
      print('[NetworkProber] bindToPhysicalNetwork error: $e');
      return false;
    }
  }

  static Future<void> unbindNetwork() async {
    print('[NetworkProber] Calling unbindNetwork()');
    if (!Platform.isAndroid) {
      print('[NetworkProber] unbindNetwork: Not Android, returning');
      return;
    }
    try {
      await _channel.invokeMethod<void>('unbindNetwork');
      print('[NetworkProber] unbindNetwork: completed successfully');
    } catch (e) {
      print('[NetworkProber] unbindNetwork error: $e');
    }
  }

  static Future<List<ProbeResult>> probeUrls({
    required List<String> urls,
    required String method,
    int timeoutMs = 10000,
    String? proxyHost,
    int? proxyPort,
    bool acceptInvalidCerts = false,
    int maxRedirects = 5,
  }) async {
    print('[NetworkProber] Calling probeUrls()');
    print('[NetworkProber] Parameters:');
    print('  - urls: ${urls.length} URLs');
    print('  - method: $method');
    print('  - timeoutMs: $timeoutMs');
    print('  - proxyHost: ${proxyHost ?? "none"}');
    print('  - proxyPort: ${proxyPort ?? "none"}');
    print('  - acceptInvalidCerts: $acceptInvalidCerts');
    print('  - maxRedirects: $maxRedirects');

    if (!Platform.isAndroid) {
      print('[NetworkProber] probeUrls: Not Android, returning empty list');
      return [];
    }

    try {
      final raw = await _channel.invokeMethod<List>('probeUrls', {
        'urls': urls,
        'method': method,
        'timeoutMs': timeoutMs,
        if (proxyHost != null) 'proxyHost': proxyHost,
        if (proxyPort != null) 'proxyPort': proxyPort,
        'acceptInvalidCerts': acceptInvalidCerts,
        'maxRedirects': maxRedirects,
      });

      if (raw == null) {
        print('[NetworkProber] probeUrls: received null result');
        return [];
      }

      final results = raw
          .whereType<Map>()
          .map((e) => ProbeResult.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      print('[NetworkProber] probeUrls: received ${results.length} results');
      for (var i = 0; i < results.length; i++) {
        print('[NetworkProber] Result ${i + 1}: ${results[i]}');
      }

      return results;
    } catch (e) {
      print('[NetworkProber] probeUrls error: $e');
      return [];
    }
  }
}