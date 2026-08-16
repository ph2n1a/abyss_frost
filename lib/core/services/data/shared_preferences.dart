import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class CallSharedPreferences extends ChangeNotifier {
  static final CallSharedPreferences instance = CallSharedPreferences._();
  CallSharedPreferences._();

  int _theme = 2;  // 0 - light | 1 - auto | 2 - dark
  bool _firstStart = true;
  bool _bypassVPN = false;
  bool _ignoreVPN = true;
  bool _doNotAnalyzeWiFi = true;
  String _pingMethod = 'Via Proxy HEAD';// Via Proxy GET/HEAD
  List<String> _targetsUrl = ['google.com', 'cloudflare.com', 'ru.devnetspace.com', 'github.com', 'yandex.ru', 'vk.ru', 'telegram.com', 'youtube.com'];
  List<String> _targetsUrlTags = ['neutral', 'neutral', 'neutral', 'neutral', 'whitelist', 'whitelist', 'blacklist', 'blacklist'];
  bool _message = false;
  int _howOftenPing = 60;
  String _rootIsolateToken = "";

  int get theme => _theme;
  bool get firstStart => _firstStart;
  bool get bypassVPN => _bypassVPN;
  bool get ignoreVPN => _ignoreVPN;
  bool get doNotAnalyzeWiFi => _doNotAnalyzeWiFi;
  String get pingMethod => _pingMethod;
  List<String> get targetsUrl => _targetsUrl;
  List<String> get targetsUrlTags => _targetsUrlTags;
  bool get message => _message;
  int get howOftenPing => _howOftenPing;
  String get rootIsolateToken => _rootIsolateToken;


  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _theme = prefs.getInt('theme') ?? 2;
    _firstStart = prefs.getBool('first_start') ?? true;
    _bypassVPN = prefs.getBool('bypass_VPN') ?? false;
    _ignoreVPN = prefs.getBool('ignore_VPN') ?? true;
    _doNotAnalyzeWiFi = prefs.getBool('do_not_analyze_wifi') ?? true;
    _pingMethod = prefs.getString('ping_method') ?? 'Via Proxy HEAD';
    _targetsUrl = prefs.getStringList('targets_URL') ?? ['google.com', 'cloudflare.com', 'ru.devnetspace.com', 'github.com', 'yandex.ru', 'vk.ru', 'telegram.org', 'youtube.com'];
    _targetsUrlTags = prefs.getStringList('targets_URL_tags') ?? ['neutral', 'neutral', 'neutral', 'neutral', 'whitelist', 'whitelist', 'blacklist', 'blacklist'];
    _message = prefs.getBool('message') ?? false;
    _howOftenPing = prefs.getInt("how_often_ping") ?? 60;
    _rootIsolateToken = prefs.getString('root_isolate_token') ?? "";
  }

  Future<void> setTheme(int value) async {
    _theme = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme', value);
    notifyListeners();
  }

  Future<void> setFirstStart(bool value) async {
    _firstStart = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_start', value);
    notifyListeners();
  }

  Future<void> setBypassVPN(bool value) async {
    _bypassVPN = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bypass_VPN', value);
    notifyListeners();
  }

  Future<void> setIgnoreVPN(bool value) async {
    _ignoreVPN = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ignore_VPN', value);
    notifyListeners();
  }

  Future<void> setDoNotAnalyzeWiFi(bool value) async {
    _doNotAnalyzeWiFi = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('do_not_analyze_wifi', value);
    notifyListeners();
  }

  Future<void> setPingMethod(String value) async {
    _pingMethod = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ping_method', value);
    notifyListeners();
  }

  Future<void> setTargetsUrl(String value, int index) async {
    _targetsUrl[index] = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('targets_URL', _targetsUrl);
    await prefs.setStringList('targets_URL_tags', _targetsUrlTags);
    notifyListeners();
  }

  Future<void> addEmptyTargetUrl() async {
    _targetsUrl.add('');
    _targetsUrlTags.add('');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('targets_URL', _targetsUrl);
    await prefs.setStringList('targets_URL_tags', _targetsUrlTags);
    notifyListeners();
  }

  Future<void> removeTargetUrl(int index) async {
    if (index >= 0 && index < _targetsUrl.length) {
      _targetsUrl.removeAt(index);
      _targetsUrlTags.removeAt(index);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('targets_URL', _targetsUrl);
      await prefs.setStringList('targets_URL_tags', _targetsUrlTags);
      notifyListeners();
    }
  }

  Future<void> setTargetsUrlTags(String value, int index) async {
    _targetsUrlTags[index] = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('targets_URL_tags', _targetsUrlTags);
    notifyListeners();
  }

  Future<void> setMessage(bool value) async {
    _message = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('message', value);
    notifyListeners();
  }

  Future<void> setHowOftenPing(int value) async {
    _howOftenPing = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('how_often_ping', value);
    notifyListeners();
  }

  Future<void> setRootIsolateToken(String value) async {
    _rootIsolateToken = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('root_isolate_token', value);
    notifyListeners();
  }
}