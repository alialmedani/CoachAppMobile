import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../app_design_system.dart';
import '../app_colors/app_colors.dart';

/// Brand-matched shadcn_ui theme for JasimExpress.
///
/// Derived from [AppDesignSystem] so shadcn components inherit the existing
/// branding (teal primary, orange accent, Cairo font, current radii) instead
/// of shadcn's default neutral look. Keep [AppDesignSystem] as the single
/// source of truth — this only mirrors it into shadcn's theme shape.
ShadThemeData buildShadLightTheme() {
  // Start from a neutral gray scheme (closest to AppDesignSystem.neutral*)
  // and override only the brand-significant slots.
  const base = ShadNeutralColorScheme.light();

  final colorScheme = base.copyWith(
    // Surfaces
    background: AppDesignSystem.surfaceWhite,
    foreground: AppDesignSystem.neutral900,
    card: AppDesignSystem.surfaceCard,
    cardForeground: AppDesignSystem.neutral900,
    popover: AppDesignSystem.surfaceWhite,
    popoverForeground: AppDesignSystem.neutral900,
    // Brand primary (teal)
    primary: AppDesignSystem.primaryColor,
    primaryForeground: AppDesignSystem.surfaceWhite,
    // Muted / neutrals
    muted: AppDesignSystem.neutral100,
    mutedForeground: AppDesignSystem.neutral500,
    // Destructive (red)
    destructive: AppDesignSystem.errorColor,
    destructiveForeground: AppDesignSystem.surfaceWhite,
    // Borders / inputs / focus ring
    border: AppDesignSystem.neutral200,
    input: AppDesignSystem.neutral300,
    ring: AppDesignSystem.primaryColor,
  );

  return ShadThemeData(
    brightness: Brightness.light,
    colorScheme: colorScheme,
    // Match the current 12px (radiusMD) corner rounding used across wrappers.
    radius: BorderRadius.circular(AppDesignSystem.radiusMD),
    // All shadcn text uses Cairo, consistent with AppDesignSystem.fontFamily.
    textTheme: ShadTextTheme(family: AppDesignSystem.fontFamily),
  );
}

/// Dark theme for shadcn_ui components
ShadThemeData buildShadDarkTheme() {
  const base = ShadNeutralColorScheme.dark();

  final colorScheme = base.copyWith(
    // Surfaces
    background: AppColors.darkScaffold,
    foreground: AppColors.darkTextPrimary,
    card: AppColors.darkCard,
    cardForeground: AppColors.darkTextPrimary,
    popover: AppColors.darkCard,
    popoverForeground: AppColors.darkTextPrimary,
    // Brand primary (red for dark mode)
    primary: AppColors.primary,
    primaryForeground: Colors.white,
    // Muted / neutrals
    muted: AppColors.darkSurfaceMuted,
    mutedForeground: AppColors.darkTextSecondary,
    // Destructive (red)
    destructive: AppColors.darkError,
    destructiveForeground: Colors.white,
    // Borders / inputs / focus ring
    border: AppColors.darkBorder,
    input: AppColors.darkBorder,
    ring: AppColors.primary,
  );

  return ShadThemeData(
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    radius: BorderRadius.circular(AppDesignSystem.radiusMD),
    textTheme: ShadTextTheme(family: AppDesignSystem.fontFamily),
  );
}
