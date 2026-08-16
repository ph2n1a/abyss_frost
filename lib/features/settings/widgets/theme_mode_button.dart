import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/data/shared_preferences.dart';

class ThemeModeSegmentedButton extends StatefulWidget {
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeChanged;

  const ThemeModeSegmentedButton({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  State<ThemeModeSegmentedButton> createState() => _ThemeModeSegmentedButtonState();
}

class _ThemeModeSegmentedButtonState extends State<ThemeModeSegmentedButton> {
  int _themeModeToInt(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 0;
      case ThemeMode.system:
        return 1;
      case ThemeMode.dark:
        return 2;
    }
  }

  void _saveThemeMode(ThemeMode mode) {
    CallSharedPreferences.instance.setTheme(_themeModeToInt(mode));
    widget.onThemeChanged(mode);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    int selectedIndex = _themeModeToInt(widget.currentTheme);

    return Container(
      height: 60,
      width: 170,
      decoration: BoxDecoration(
        color: appColors.backColor,
        borderRadius: BorderRadius.circular(50),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0 + (selectedIndex * 55),
            top: 5,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: appColors.mediumColor,
                borderRadius: BorderRadius.only(
                  topLeft: switch (selectedIndex) {
                    0 => Radius.circular(50),
                    1 => Radius.circular(5),
                    2 => Radius.circular(5),
                    _ => Radius.zero,
                  },
                  bottomLeft: switch (selectedIndex) {
                    0 => Radius.circular(50),
                    1 => Radius.circular(5),
                    2 => Radius.circular(5),
                    _ => Radius.zero,
                  },
                  topRight: switch (selectedIndex) {
                    0 => Radius.circular(5),
                    1 => Radius.circular(5),
                    2 => Radius.circular(50),
                    _ => Radius.zero,
                  },
                  bottomRight: switch (selectedIndex) {
                    0 => Radius.circular(5),
                    1 => Radius.circular(5),
                    2 => Radius.circular(50),
                    _ => Radius.zero,
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 2
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSegment(
                  icon: Icons.brightness_high,
                  themeMode: ThemeMode.light,
                  appColors: appColors,
                  isSelected: widget.currentTheme == ThemeMode.light,
                  position: 0,
                ),
                _buildSegment(
                  icon: Icons.brightness_auto,
                  themeMode: ThemeMode.system,
                  appColors: appColors,
                  isSelected: widget.currentTheme == ThemeMode.system,
                  position: 1,
                ),
                _buildSegment(
                  icon: Icons.brightness_2,
                  themeMode: ThemeMode.dark,
                  appColors: appColors,
                  isSelected: widget.currentTheme == ThemeMode.dark,
                  position: 2,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSegment({
    required IconData icon,
    required bool isSelected,
    required ThemeMode themeMode,
    required AppColors appColors,
    required int position,
  }) {
    return GestureDetector(
      onTap: () => _saveThemeMode(themeMode),
      child: SizedBox(
        height: 60,
        width: 50,
        child: Center(
          child: Icon(
            icon,
            color: isSelected ? Colors.white : appColors.mainColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}