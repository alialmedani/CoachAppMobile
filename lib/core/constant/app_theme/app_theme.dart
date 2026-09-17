import 'package:flutter/material.dart';

import '../apex_colors/apex_colors.dart';
import '../app_colors/app_colors.dart';

enum AppTheme { dark, light }

final Map<AppTheme, ThemeData> appThemeData = {
  AppTheme.light: ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secoundPrimary,
      surface: AppColors.white,
      error: AppColors.danger,
    ),
    primaryColor: AppColors.neutral,
    scaffoldBackgroundColor: AppColors.danger100,
    secondaryHeaderColor: AppColors.lightSubHeadingColor1,
    canvasColor: AppColors.neutral50,
    cardColor: AppColors.white,
    dialogTheme: DialogThemeData(backgroundColor: AppColors.neutral50),
    fontFamily: "Cairo",
    disabledColor: AppColors.success100,
    iconTheme: const IconThemeData(color: Colors.black54),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 18),
    ),
    textTheme: const TextTheme().apply(
      bodyColor: AppColors.neutral900,
      displayColor: AppColors.neutral900,
    ),
  ),

  // Apex v3 — the shipping "hero" mode (main.dart forces ThemeMode.dark).
  AppTheme.dark: ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: ApexColors.volt,
      onPrimary: ApexColors.onLime,
      secondary: ApexColors.blaze,
      onSecondary: ApexColors.onBlaze,
      surface: ApexColors.darkRaised,
      onSurface: ApexColors.darkText,
      error: ApexColors.critDark,
    ),
    primaryColor: ApexColors.volt,
    scaffoldBackgroundColor: ApexColors.darkCanvas,
    secondaryHeaderColor: ApexColors.darkMuted,
    canvasColor: ApexColors.darkRaised,
    cardColor: ApexColors.darkRaised,
    disabledColor: ApexColors.darkFaint,
    dialogTheme: const DialogThemeData(backgroundColor: ApexColors.darkOverlay),
    fontFamily: "Cairo",
    iconTheme: const IconThemeData(color: ApexColors.darkText),
    appBarTheme: const AppBarTheme(
      backgroundColor: ApexColors.darkRaised,
      iconTheme: IconThemeData(color: ApexColors.darkText),
      titleTextStyle: TextStyle(color: ApexColors.darkText, fontSize: 18),
    ),
    textTheme: const TextTheme().apply(
      bodyColor: ApexColors.darkText,
      displayColor: ApexColors.darkText,
    ),
  ),
};
