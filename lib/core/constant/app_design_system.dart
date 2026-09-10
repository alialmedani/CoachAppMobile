import 'package:flutter/material.dart';

/// Modern Design System for JasimExpress
/// Professional, clean, and merchant-friendly
class AppDesignSystem {
  // ==================== COLORS ====================

  /// Primary brand color - Professional teal/blue
  static const Color primaryColor = Color(0xFF0F766E); // Teal 700
  static const Color primaryLight = Color(0xFF14B8A6); // Teal 500
  static const Color primaryDark = Color(0xFF0D5B52); // Teal 800
  static const Color primarySurface = Color(0xFFCCFBF1); // Teal 100

  /// Secondary/Accent color - Vibrant orange for CTAs
  static const Color accentColor = Color(0xFFF97316); // Orange 500
  static const Color accentLight = Color(0xFFFB923C); // Orange 400
  static const Color accentDark = Color(0xFFEA580C); // Orange 600
  static const Color accentSurface = Color(0xFFFFEDD5); // Orange 100

  /// Neutral colors - Clean gray scale
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  /// Status colors
  static const Color successColor = Color(0xFF10B981); // Green 500
  static const Color successLight = Color(0xFF34D399); // Green 400
  static const Color successSurface = Color(0xFFD1FAE5); // Green 100

  static const Color errorColor = Color(0xFFEF4444); // Red 500
  static const Color errorLight = Color(0xFFF87171); // Red 400
  static const Color errorSurface = Color(0xFFFEE2E2); // Red 100

  static const Color warningColor = Color(0xFFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFBBF24); // Amber 400
  static const Color warningSurface = Color(0xFFFEF3C7); // Amber 100

  static const Color infoColor = Color(0xFF3B82F6); // Blue 500
  static const Color infoLight = Color(0xFF60A5FA); // Blue 400
  static const Color infoSurface = Color(0xFFDBEAFE); // Blue 100

  /// Surface colors
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceCard = Color(0xFFFFFFFF);

  // ==================== TYPOGRAPHY ====================

  /// Font family
  static const String fontFamily = 'Cairo';

  /// Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  /// Font sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeSM = 12.0;
  static const double fontSizeBase = 14.0;
  static const double fontSizeLG = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSize2XL = 20.0;
  static const double fontSize3XL = 24.0;
  static const double fontSize4XL = 28.0;
  static const double fontSize5XL = 32.0;

  /// Text styles
  static TextStyle h1 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize5XL,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle h2 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize4XL,
    fontWeight: bold,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static TextStyle h3 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize3XL,
    fontWeight: semiBold,
    height: 1.3,
  );

  static TextStyle h4 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize2XL,
    fontWeight: semiBold,
    height: 1.4,
  );

  static TextStyle h5 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeXL,
    fontWeight: semiBold,
    height: 1.4,
  );

  static TextStyle h6 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeLG,
    fontWeight: semiBold,
    height: 1.4,
  );

  static TextStyle bodyLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeLG,
    fontWeight: regular,
    height: 1.5,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeBase,
    fontWeight: regular,
    height: 1.5,
  );

  static TextStyle bodySmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeSM,
    fontWeight: regular,
    height: 1.5,
  );

  static TextStyle labelLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeBase,
    fontWeight: medium,
    height: 1.4,
  );

  static TextStyle labelMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeSM,
    fontWeight: medium,
    height: 1.4,
  );

  static TextStyle labelSmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeXS,
    fontWeight: medium,
    height: 1.4,
  );

  // ==================== SPACING ====================

  static const double spacing2XS = 4.0;
  static const double spacingXS = 8.0;
  static const double spacingSM = 12.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 20.0;
  static const double spacingXL = 24.0;
  static const double spacing2XL = 32.0;
  static const double spacing3XL = 40.0;
  static const double spacing4XL = 48.0;

  // ==================== BORDER RADIUS ====================

  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radius2XL = 24.0;
  static const double radiusFull = 9999.0;

  // ==================== SHADOWS ====================

  static List<BoxShadow> shadowSM = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> shadowMD = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowLG = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowXL = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // ==================== DURATIONS ====================

  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);

  // ==================== CURVES ====================

  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveEmphasized = Curves.easeOutCubic;

  // ==================== ICON SIZES ====================

  static const double iconSizeXS = 16.0;
  static const double iconSizeSM = 20.0;
  static const double iconSizeMD = 24.0;
  static const double iconSizeLG = 32.0;
  static const double iconSizeXL = 40.0;
  static const double iconSize2XL = 48.0;
}
