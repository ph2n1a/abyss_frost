import 'package:flutter/material.dart';

class MyThemeColors {
  // light theme
  static const AppColors light = AppColors(
    mainColor: Color(0xFFC0D9FF),
    accentColor: Color(0xFFE4F0F6),
    mediumColor: Color(0xFF8B9AB7),
    backColor: Color(0xFF4C5365),
    backgroundColor: Color(0xFFF1F5F9),
    gray: Color(0xFF7E7E7E),
  );

  // dark theme
  static const AppColors dark = AppColors(
    mainColor: Color(0xFF101827),
    accentColor: Color(0xFF1F2125),
    mediumColor: Color(0xFF607693),
    backColor: Color(0xFFE4F0F6),
    backgroundColor: Color(0xFF0A0F1E),
    gray: Color(0xFF333333),
  );
}

class AppColors extends ThemeExtension<AppColors> {
  final Color mainColor;
  final Color accentColor;
  final Color mediumColor;
  final Color backColor;
  final Color backgroundColor;
  final Color gray;

  const AppColors({
    required this.mainColor,
    required this.accentColor,
    required this.mediumColor,
    required this.backColor,
    required this.backgroundColor,
    required this.gray,
  });

  @override
  ThemeExtension<AppColors> copyWith({
    Color? mainColorOverride,
    Color? accentColorOverride,
    Color? mediumColorOverride,
    Color? backColorOverride,
    Color? backgroundColorOverride,
    Color? grayOverride,
  }) {
    return AppColors(
      mainColor: mainColorOverride ?? mainColor,
      accentColor: accentColorOverride ?? accentColor,
      mediumColor: mediumColorOverride ?? mediumColor,
      backColor: backColorOverride ?? backColor,
      backgroundColor: backgroundColorOverride ?? backgroundColor,
      gray: grayOverride ?? gray,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      mainColor: Color.lerp(mainColor, other.mainColor, t)!,
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
      mediumColor: Color.lerp(mediumColor, other.mediumColor, t)!,
      backColor: Color.lerp(backColor, other.backColor, t)!,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      gray: Color.lerp(gray, other.gray, t)!,
    );
  }
}
