import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: MyThemeColors.light.backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: MyThemeColors.light.mediumColor,
      brightness: Brightness.light,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      MyThemeColors.light,
    ],
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: MyThemeColors.dark.backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: MyThemeColors.dark.mediumColor,
      brightness: Brightness.dark,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      MyThemeColors.dark,
    ],
  );
}