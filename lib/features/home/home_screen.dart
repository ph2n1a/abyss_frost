import 'package:abyss_frost/core/services/data/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'widgets/start_button.dart';
import '../../core/theme/app_colors.dart';
import '../main/domain/background_service_controller.dart';
import 'widgets/live_ping_view.dart';
import 'package:abyss_frost/core/database/app_database.dart';
import 'package:abyss_frost/features/home/widgets/network_state_now.dart';

class HomeScreen extends StatefulWidget {
  final PingServiceController service;
  final AppDatabase db;

  const HomeScreen({
    super.key,
    required this.service,
    required this.db,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double scale = 1;

  Future<void> _toggleNotificationsAnimation() async {
    setState(() => scale = 0.9);
    await Future.delayed(const Duration(milliseconds: 130));
    if (mounted) setState(() => scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            const SizedBox(height: 120),

            Column(
              children: [
                StartButton(service: widget.service),

                const SizedBox(height: 40),

                AnimatedScale(
                  scale: scale,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInOut,
                  child: IconButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(const Color(0xFF333333)),
                      padding: WidgetStateProperty.all(const EdgeInsets.all(12.0)),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        CallSharedPreferences.instance.setMessage(!CallSharedPreferences.instance.message);
                        _toggleNotificationsAnimation();
                      });
                    },
                    color: appColors.accentColor,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 130),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        CallSharedPreferences.instance.message
                            ? Icons.notifications_on_outlined
                            : Icons.notifications_off_outlined,
                        key: ValueKey<bool>(CallSharedPreferences.instance.message),
                        color: appColors.backColor,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            NetworkStateNow(court: widget.service.court),

            const SizedBox(height: 10),

            LivePingView(state: widget.service.liveState),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
