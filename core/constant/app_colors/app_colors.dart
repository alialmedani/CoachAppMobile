import 'package:flutter/material.dart';

extension AppColors on ColorScheme {
  static Color primary = const Color(0xffD40511);
  static Color secoundPrimary = const Color(0xffFFCC00);
  static const Color lighterBackground = Color(0xffF8F9FC);
  static const Color success = Color(0xff28A745);

  static const Color danger = Color(0xffD32F2F);
  static const Color warning = Color(0xffFF9800);
  static const Color info = Color(0xff42A5F5);

  static Color primary25 = const Color(0xffF1F7F6);
  static Color primary50 = const Color(0xffE3F0ED);
  static Color primary100 = const Color(0xffD1E9E3);
  static Color primary200 = const Color(0xffA4D4D5);
  static Color primary300 = const Color(0xff81C9C5);
  static Color primary400 = const Color(0xff72C1C1);
  static Color primary600 = const Color(0xff1F6568);
  static Color primary700 = const Color(0xff14584B);
  static Color primary800 = const Color(0xff0E2F29);
  static Color primary900 = const Color(0xff012D26);

  static const Color neutral25 = Color(0xffFAFAFA);
  static const Color neutral50 = Color(0xffF2F2F2);
  static const Color neutral100 = Color(0xffE8E8E8);
  static const Color neutral200 = Color(0xffD9D9D9);
  static const Color neutral300 = Color(0xffC2C2C2);
  static const Color neutral400 = Color(0xffA3A3A3);
  static const Color neutral600 = Color(0xff666666);
  static const Color neutral700 = Color(0xff4D4D4D);
  static const Color neutral800 = Color(0xff333333);
  static const Color neutral900 = Color(0xff1A1A1A);

  static const Color success100 = Color(0xffD0F1D4);
  static const Color success800 = Color(0xff0C731A);

  static const Color danger100 = Color(0xffF6D0D0);
  static const Color danger800 = Color(0xff630D0D);

  static const Color info25 = Color(0xffF5FAFF);
  static const Color info100 = Color(0xffDDEFFD);

  // Light / Dark helpers
  static Color lightSecondaryColor = const Color(0xffFFFFFF);
  static Color lightSubHeadingColor1 = const Color(0xff343F53);
  static Color background = const Color(0xFFe8e8e8);

  static Color darkSubHeadingColor1 = const Color(0xDDF2F1F6);

  Color get blackColor => brightness == Brightness.light
      ? lightSubHeadingColor1
      : darkSubHeadingColor1;

  Color get primaryColor =>
      brightness == Brightness.light ? primary : darkSubHeadingColor1;

  Color get secondaryColor => brightness == Brightness.light
      ? lightSecondaryColor
      : darkSubHeadingColor1;

  static const Color black = Color(0xFF000000);
  static const Color black1c = Color(0xFF1C1C1C);
  static const Color black14 = Color(0xFF141414);
  static const Color grey9A = Color(0xFF9A9A9A);
  static const Color greyDD = Color(0xFFDDE2E4);
  static const Color grey89 = Color(0xFF898989);
  static const Color grey72 = Color(0xFF727272);

  static const Color chineseBlack = Color(0xFF0D0D12);
  static const Color auroMetalSaurus = Color(0xFF666D80);
  static const Color brightGray = Color(0xFFECEFF3);
  static const Color white = Color(0xFFFFFFFF);

  static const Color philippineRed = Color(0xFFD01725);
  static const Color crimson = Color(0xFFDF1C41);
  static const Color pastelOrange = Color(0xFFFFBE4C);
  static const Color verdigris = Color(0xFF40C4AA);

  static const Color neutral = Color(0xFF808080);

  // UI specific colors
  // UI Light colors
  static const Color lightScaffold = Color(0xFFF9FAFB);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE8EAF0);
  static const Color lightSurfaceMuted = Color(0xFFF3F4F6);
  static const Color lightTextStrong = Color(0xFF374151);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);
  static const Color lightError = Color(0xFFEF4444);
  static const Color lightCardSoft = Color(0xFFFBFBFB);
  static const Color lightBackgroundSoft = Color(0xFFF9FAFB);
  static const Color lightIconMuted = Color(0xFFD1D5DB);

  // UI Dark colors
  static const Color darkScaffold = Color(0xFF17181D);
  static const Color darkCard = Color(0xFF1E1F26);
  static const Color darkCardSoft = Color(0xFF171821);
  static const Color darkTextPrimary = Color(0xFFE5E7EB);
  static const Color darkTextSecondary = Color(0xFFA8ACB8);
  static const Color darkTextStrong = Color(0xFFF3F4F6);
  static const Color darkTextTertiary = Color(0xFF6B7280);
  static const Color darkBorder = Color(0xFF2D2F3A);
  static const Color darkSurfaceMuted = Color(0xFF252731);
  static const Color darkBackgroundSoft = Color(0xFF1A1B24);
  static const Color darkIconMuted = Color(0xFF4B5563);
  static const Color darkError = Color(0xFFEF4444);

  bool get isDark => brightness == Brightness.dark;

  Color get appScaffold => isDark ? darkScaffold : lightScaffold;

  Color get appCard => isDark ? darkCard : white;

  Color get appCardSoft => isDark ? darkCardSoft : lightCardSoft;

  Color get appText => isDark ? darkTextPrimary : lightTextPrimary;

  Color get appTextStrong => isDark ? darkTextStrong : lightTextStrong;

  Color get appTextSecondary => isDark ? darkTextSecondary : lightTextSecondary;

  Color get appTextTertiary => isDark ? darkTextTertiary : lightTextTertiary;

  Color get appBorder => isDark ? darkBorder : lightBorder;

  Color get appSurfaceMuted => isDark ? darkSurfaceMuted : lightSurfaceMuted;

  Color get appBackgroundSoft =>
      isDark ? darkBackgroundSoft : lightBackgroundSoft;

  Color get appIconMuted => isDark ? darkIconMuted : lightIconMuted;

  Color get appError => isDark ? darkError : lightError;

  // Helper method to get primary color based on theme
  Color get appPrimary => primary;

  // Helper method to get text on primary color
  Color get appOnPrimary => Colors.white;

  // Helper method to get shadow color based on theme
  Color get appShadow =>
      isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04);
}
