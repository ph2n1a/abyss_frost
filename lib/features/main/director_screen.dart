import 'package:abyss_frost/core/database/app_database.dart';
import 'package:flutter/material.dart';

import '../logs/logs_screen.dart';
import '../home/home_screen.dart';
import '../settings/settings_screen.dart';
import '../statistics/statistics_screen.dart';
import './widgets/navigation_widget.dart';
import './domain/background_service_controller.dart';

class DirectorScreen extends StatefulWidget {
  final AppDatabase db;

  const DirectorScreen({
    super.key,
    required this.db,
  });

  @override
  State<DirectorScreen> createState() => _DirectorScreenState();
}

class _DirectorScreenState extends State<DirectorScreen> {
  int _selectedScreenIndex = 0;
  List<double> scale = [1, 1, 1, 1];

  late final PingServiceController _globalService;

  @override
  void initState() {
    super.initState();
    _globalService = PingServiceController(widget.db);
    _globalService.initialize();
  }

  @override
  void dispose() {
    _globalService.dispose();
    super.dispose();
  }

  List<Widget> get _screens => [
    HomeScreen(
      service: _globalService,
      db: widget.db,
    ),
    const StatisticsScreen(),
    const LogsScreen(),
    const SettingsScreen(),
  ];

  Future<void> _onItemTapped(int index) async {
    setState(() => _selectedScreenIndex = index);
    setState(() => scale[index] = 0.8);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) setState(() => scale[index] = 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            _screens[_selectedScreenIndex],
            NavigationWidget(
              selectedIndex: _selectedScreenIndex,
              scale: scale,
              onItemTapped: _onItemTapped,
            ),
          ],
        ),
      ),
    );
  }
}