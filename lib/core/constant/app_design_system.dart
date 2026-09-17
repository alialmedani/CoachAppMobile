import 'package:flutter/material.dart';

import 'apex_colors/apex_colors.dart';

/// Apex v3 Design System for CoachApp.
///
/// DARK-FIRST. These static tokens are re-pointed at [ApexColors]' dark palette
/// so the whole app (~2000 call sites) re-skins from one place, with no need to
/// migrate call sites to a context resolver.
class AppDesignSystem {
  // ==================== COLORS ====================

  /// Primary brand — Volt acid lime. Text placed ON it MUST be [onPrimary]
  /// (ink), never white — white-on-lime is a hard contrast fail.
  static const Color primaryColor = ApexColors.volt;
  static const Color primaryLight = ApexColors.voltStrongDark;
  static const Color primaryDark = ApexColors.voltDeep;
  static const Color primarySurface = ApexColors.limeSoftDark;
  static const Color onPrimary = ApexColors.onLime;
  static const Color primaryStrong = ApexColors.voltStrongDark;

  /// Secondary/energy — Blaze orange.
  static const Color accentColor = ApexColors.blaze;
  static const Color accentLight = ApexColors.blazeStrongDark;
  static const Color accentDark = ApexColors.blazeStrongLight;
  static const Color accentSurface = ApexColors.blazeSoftDark;
  static const Color onAccent = ApexColors.onBlaze;

  /// Neutral scale — INVERTED for dark-first.
  ///
  /// In Apex the ramp means: HIGH number = TEXT (light), LOW number = SURFACE
  /// (dark). This inversion is deliberate — the codebase uses `neutral900` as
  /// primary text and `neutral50/100` as surfaces, so inverting re-skins both
  /// correctly in one move. DO NOT "fix" this back to a light→dark ramp.
  static const Color neutral50 = ApexColors.darkRaised; // raised surface
  static const Color neutral100 = ApexColors.darkSunken; // sunken / chip fill
  static const Color neutral200 = ApexColors.darkBorder; // border / divider
  static const Color neutral300 = ApexColors.darkBorderStrong; // strong border
  static const Color neutral400 = ApexColors.darkFaint; // faint text
  static const Color neutral500 = ApexColors.darkMuted; // muted text
  static const Color neutral600 = Color(0xFFB4B9AF); // secondary text
  static const Color neutral700 = Color(0xFFCBCFC6); // secondary/strong text
  static const Color neutral800 = Color(0xFFE2E4DD); // near-primary text
  static const Color neutral900 = ApexColors.darkText; // primary text

  /// Status colors
  static const Color successColor = ApexColors.goodDark;
  static const Color successLight = Color(0xFF5BD9B0);
  static const Color successSurface = ApexColors.goodSoftDark;

  static const Color errorColor = ApexColors.critDark;
  static const Color errorLight = Color(0xFFF58480);
  static const Color errorSurface = ApexColors.critSoftDark;

  static const Color warningColor = ApexColors.warnDark;
  static const Color warningLight = Color(0xFFF0C06B);
  static const Color warningSurface = ApexColors.warnSoftDark;

  static const Color infoColor = ApexColors.infoDark;
  static const Color infoLight = Color(0xFF79A6EF);
  static const Color infoSurface = ApexColors.infoSoftDark;

  /// Surface colors — dark-first.
  static const Color surfaceWhite = ApexColors.darkRaised;
  static const Color surfaceLight = ApexColors.darkCanvas;
  static const Color surfaceCard = ApexColors.darkRaised;

  /// Semantic surface/text aliases (theme-agnostic names for the seam).
  static const Color surfaceCanvas = ApexColors.darkCanvas;
  static const Color surfaceRaised = ApexColors.darkRaised;
  static const Color surfaceSunken = ApexColors.darkSunken;
  static const Color surfaceOverlay = ApexColors.darkOverlay;
  static const Color borderColor = ApexColors.darkBorder;
  static const Color borderStrong = ApexColors.darkBorderStrong;
  static const Color textPrimary = ApexColors.darkText;
  static const Color textMuted = ApexColors.darkMuted;
  static const Color textFaint = ApexColors.darkFaint;

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
