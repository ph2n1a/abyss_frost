import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'core/database/app_database.dart';
import 'features/main/director_screen.dart';
import 'core/services/data/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await getDatabase();
  await CallSharedPreferences.instance.init();

  final token = RootIsolateToken.instance;
  if (token != null) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
  }

  runApp(
    Provider<AppDatabase>.value(
      value: db,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    CallSharedPreferences.instance.addListener(_onThemePreferenceChanged);
  }

  @override
  void dispose() {
    CallSharedPreferences.instance.removeListener(_onThemePreferenceChanged);
    super.dispose();
  }

  void _loadTheme() {
    final themeIndex = CallSharedPreferences.instance.theme;
    _themeMode = _intToThemeMode(themeIndex);
  }

  void _onThemePreferenceChanged() {
    setState(() {
      _loadTheme();
    });
  }

  ThemeMode _intToThemeMode(int value) {
    switch (value) {
      case 0:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context, listen: false);
    return MaterialApp(
      locale: const Locale('en', 'GB'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'GB'),
      ],
      themeMode: _themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: DirectorScreen(
        db: db,
      ),
    );
  }
}
