import 'package:flutter/material.dart';

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

  AppTheme.dark: ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      secondary: AppColors.secoundPrimary,
      surface: AppColors.darkCard,
      error: AppColors.darkError,
    ),
    primaryColor: AppColors.white,
    scaffoldBackgroundColor: AppColors.danger800,
    secondaryHeaderColor: AppColors.neutral300,
    canvasColor: AppColors.neutral700,
    cardColor: AppColors.neutral800,
    disabledColor: AppColors.success800,
    dialogTheme: DialogThemeData(backgroundColor: Color(0xFF1F1F1F)),
    fontFamily: "Cairo",
    iconTheme: const IconThemeData(color: Colors.white70),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1C1C1E),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
    ),
    textTheme: const TextTheme().apply(
      bodyColor: AppColors.primary25,
      displayColor: AppColors.primary25,
    ),
  ),
};
