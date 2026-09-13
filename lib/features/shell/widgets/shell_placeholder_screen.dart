import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Lightweight placeholder body for a shell tab whose real feature screen lands
/// in a later phase. Renders the section header (via [AppTopBar]) plus a
/// localized "coming soon" empty state.
///
/// Each real feature screen replaces its placeholder in the phase noted on the
/// tab definition in the shells.
class ShellPlaceholderScreen extends StatelessWidget {
  /// snake_case translation key used for the section title.
  final String titleKey;

  /// Illustrative icon for the empty state.
  final IconData icon;

  const ShellPlaceholderScreen({
    super.key,
    required this.titleKey,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(title: titleKey.tr()),
      body: AppEmptyState(
        icon: icon,
        title: 'coming_soon'.tr(),
        subtitle: 'coming_soon_subtitle'.tr(),
        iconColor: AppDesignSystem.primaryColor,
      ),
    );
  }
}
