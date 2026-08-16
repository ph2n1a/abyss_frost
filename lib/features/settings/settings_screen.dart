import 'package:abyss_frost/core/widgets/number_field.dart';
import 'screens/data_cleanup_screen.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/data/shared_preferences.dart';
import 'widgets/theme_mode_button.dart';
import 'widgets/settings_block.dart';
import 'screens/target_url_screen.dart';
import 'package:provider/provider.dart';
import 'package:abyss_frost/core/database/app_database.dart';
import 'widgets/credits_footer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _currentTheme = ThemeMode.system;
  final List<String> items = ['Via Proxy HEAD', 'Via Proxy GET'];
  final ValueNotifier<int> howOftenPing = ValueNotifier<int>(
    CallSharedPreferences.instance.howOftenPing,
  );

  @override
  void initState() {
    super.initState();
    _loadTheme();
    CallSharedPreferences.instance.addListener(_onThemeChanged);
    howOftenPing.addListener(() {
      CallSharedPreferences.instance.setHowOftenPing(howOftenPing.value);
    });
  }

  @override
  void dispose() {
    CallSharedPreferences.instance.removeListener(_onThemeChanged);
    howOftenPing.dispose();
    super.dispose();
  }

  void _loadTheme() {
    final themeIndex = CallSharedPreferences.instance.theme;
    _currentTheme = _intToThemeMode(themeIndex);
  }

  void _onThemeChanged() {
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
    final appColors = Theme.of(context).extension<AppColors>()!;
    final db = Provider.of<AppDatabase>(context, listen: false);
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 15,
              right: 40,
              left: 37,
              bottom: 20,
            ),
            child: Text(
              "Settings",
              style: TextStyle(
                fontSize: 30,
                color: appColors.backColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              "Themes",
              style: TextStyle(
                color: appColors.backColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SettingsBlock(
            icon: Icon(Icons.palette_outlined, color: appColors.mainColor),
            header: "Theme",
            description: "Change theme",
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: ThemeModeSegmentedButton(
                currentTheme: _currentTheme,
                onThemeChanged: (mode) {
                  setState(() {
                    _currentTheme = mode;
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, top: 5),
            child: Text(
              "App control",
              style: TextStyle(
                color: appColors.backColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SettingsBlock(
            icon: Icon(Icons.vpn_key_off_outlined, color: appColors.mainColor),
            header: "Ignore VPN",
            description: "If the VPN is enabled, there will be no ping.",
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Switch(
                activeTrackColor: appColors.backColor,
                activeThumbColor: appColors.mainColor,
                value: CallSharedPreferences.instance.ignoreVPN,
                onChanged: (value) {
                  CallSharedPreferences.instance.setIgnoreVPN(value);
                },
              ),
            ),
          ),
          SettingsBlock(
            icon: Icon(Icons.switch_access_shortcut, color: appColors.mainColor),
            header: "Try bypass VPN",
            description: "When VPN is enabled, ping try bypassing it",
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Switch(
                activeTrackColor: appColors.backColor,
                activeThumbColor: appColors.mainColor,
                value: CallSharedPreferences.instance.bypassVPN,
                onChanged: (value) {
                  CallSharedPreferences.instance.setBypassVPN(value);
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(left: 10, right: 10, bottom: 5),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  topRight: Radius.circular(5),
                  topLeft: Radius.circular(5),
                ),
                color: appColors.accentColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      width: 50,
                      height: 100,
                      decoration: BoxDecoration(
                        color: appColors.backColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Icons.arrow_upward, color: appColors.mainColor, size: 30,),
                          Icon(Icons.info, color: appColors.mainColor, size: 30,),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "This feature can only bypass a small number of VPNs due to the complexity of Android's architecture. "
                            "To use it, you must disable the \"Block connections without VPN\" setting, and it is not recommended to use TUN.",
                        style: TextStyle(
                          color: appColors.backColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SettingsBlock(
            icon: Icon(
              Icons.signal_wifi_bad_outlined,
              color: appColors.mainColor,
            ),
            header: "Don't ping in Wi-Fi",
            description:
                "When the phone is connected to Wi-Fi, the app won't work",
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Switch(
                activeTrackColor: appColors.backColor,
                activeThumbColor: appColors.mainColor,
                value: CallSharedPreferences.instance.doNotAnalyzeWiFi,
                onChanged: (value) {
                  CallSharedPreferences.instance.setDoNotAnalyzeWiFi(value);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 5),
            child: Text(
              "Data",
              style: TextStyle(
                color: appColors.backColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DataCleanupScreen(
                  db: db,
                )),
              );
            },
            child: SettingsBlock(
              icon: Icon(Icons.auto_delete_outlined, color: appColors.mainColor),
              header: "Ping history",
              description: "Delete saved months from database",
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Icon(
                  Icons.arrow_forward_ios_sharp,
                  color: appColors.backColor,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, top: 5),
            child: Text(
              "Ping control",
              style: TextStyle(
                color: appColors.backColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SettingsBlock(
            icon: Icon(Icons.network_ping_outlined, color: appColors.mainColor),
            header: "Ping",
            description: "Select method",
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 5),
                height: 50,
                decoration: BoxDecoration(
                  color: appColors.backColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                  child: DropdownButton<String>(
                    key: ValueKey(CallSharedPreferences.instance.pingMethod),
                    value: CallSharedPreferences.instance.pingMethod,
                    items: items
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: appColors.mainColor
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (newVal) {
                      setState(() {
                        CallSharedPreferences.instance.setPingMethod(newVal!);
                      });
                    },
                    dropdownColor: appColors.backColor,
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(12),
                    icon: Icon(Icons.keyboard_arrow_down_outlined, color: appColors.accentColor),
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TargetUrlScreen()),
              );
            },
            child: SettingsBlock(
              icon: Icon(Icons.http_sharp, color: appColors.mainColor),
              header: "Targets URL",
              description: "Selected URL for ping",
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Icon(
                  Icons.arrow_forward_ios_sharp,
                  color: appColors.backColor,
                ),
              ),
            ),
          ),
          SettingsBlock(
            icon: Icon(Icons.timelapse_sharp, color: appColors.mainColor),
            header: "How often ping",
            description:
                "At least 60 seconds is recommended. Restart after changing!",
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: NumberField(
                    number: howOftenPing,
                    minValue: 5,
                    maxValue: 7200,
                    hintText: "seconds",
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Text(
                    "sec",
                    style: TextStyle(
                      color: appColors.backColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          const CreditsFooter(),

          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
