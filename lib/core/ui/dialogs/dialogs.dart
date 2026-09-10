import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../classes/keys.dart';
import '../../constant/app_design_system.dart';

/// The visual variant of an app toast.
enum AppToastVariant { success, error, info }

/// App-wide toast/notification helper.
///
/// Re-implemented on top of shadcn's [ShadToaster] / [ShadToast] for a clean,
/// formal, modern look that matches the driver-feature quality bar. The public
/// API ([showSnackBar] / [showErrorSnackBar]) is unchanged so every existing
/// call site keeps compiling without edits — they are simply routed through the
/// new shadcn toaster under the hood.
///
/// Styling is driven entirely by [AppDesignSystem] tokens (brand colors, radii,
/// shadows, spacing, typography) — no hardcoded values. Toasts appear at the
/// TOP of the screen (cleaner for a polished app, avoids the bottom nav / FAB /
/// keyboard), auto-dismiss after ~2.5s, are RTL-correct, and carry a leading
/// status icon (success = check/teal-green, error = destructive/red,
/// info = neutral).
class Dialogs {
  Dialogs._();

  /// How long a toast stays visible before auto-dismissing.
  static const Duration _toastDuration = Duration(milliseconds: 2500);

  /// Where toasts are anchored. Top is the cleaner choice for this app.
  static const Alignment _toastAlignment = Alignment.topCenter;

  /// Shows an informational/success toast.
  ///
  /// Backwards-compatible signature: existing callers pass only [message].
  /// The legacy [typeSnackBar] parameter is still accepted (so old call sites
  /// compile unchanged) and is mapped onto the new variants; new callers should
  /// prefer the [variant] parameter instead.
  static void showSnackBar({
    required String message,
    AnimatedSnackBarType typeSnackBar = AnimatedSnackBarType.success,
    AppToastVariant? variant,
    String? description,
  }) {
    _show(
      message: message,
      variant: variant ?? _fromLegacy(typeSnackBar),
      description: description,
    );
  }

  /// Shows an error/destructive toast.
  ///
  /// Backwards-compatible signature: existing callers pass only [message].
  static void showErrorSnackBar({
    required String message,
    AnimatedSnackBarType typeSnackBar = AnimatedSnackBarType.error,
    String? description,
  }) {
    _show(
      message: message,
      variant: AppToastVariant.error,
      description: description,
    );
  }

  /// Convenience entry points for new code (clearer than the legacy names).
  static void showSuccess(String message, {String? description}) =>
      _show(message: message, variant: AppToastVariant.success, description: description);

  static void showError(String message, {String? description}) =>
      _show(message: message, variant: AppToastVariant.error, description: description);

  static void showInfo(String message, {String? description}) =>
      _show(message: message, variant: AppToastVariant.info, description: description);

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  static AppToastVariant _fromLegacy(AnimatedSnackBarType type) {
    switch (type) {
      case AnimatedSnackBarType.error:
        return AppToastVariant.error;
      case AnimatedSnackBarType.warning:
      case AnimatedSnackBarType.info:
        return AppToastVariant.info;
      case AnimatedSnackBarType.success:
        return AppToastVariant.success;
    }
  }

  static void _show({
    required String message,
    required AppToastVariant variant,
    String? description,
  }) {
    // These helpers are called from many context-less spots (cubits, async
    // callbacks, the double-back guard). Resolve the global navigator context
    // which lives INSIDE the ShadApp/ShadToaster subtree.
    final context = Keys.navigatorKey.currentContext;
    if (context == null) return;

    final toaster = ShadToaster.maybeOf(context);
    if (toaster == null) {
      // Extremely unlikely (ShadApp always provides a toaster), but never crash
      // over a notification — degrade to the framework messenger if present.
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    toaster.show(_buildToast(variant: variant, message: message, description: description));
  }

  static ShadToast _buildToast({
    required AppToastVariant variant,
    required String message,
    String? description,
  }) {
    final ({Color icon, Color background, Color border, Color foreground, IconData glyph}) tokens =
        switch (variant) {
      AppToastVariant.success => (
          icon: AppDesignSystem.successColor,
          background: AppDesignSystem.surfaceWhite,
          border: AppDesignSystem.successColor.withValues(alpha: 0.30),
          foreground: AppDesignSystem.neutral900,
          glyph: LucideIcons.circleCheck,
        ),
      AppToastVariant.error => (
          icon: AppDesignSystem.errorColor,
          background: AppDesignSystem.surfaceWhite,
          border: AppDesignSystem.errorColor.withValues(alpha: 0.30),
          foreground: AppDesignSystem.neutral900,
          glyph: LucideIcons.circleAlert,
        ),
      AppToastVariant.info => (
          icon: AppDesignSystem.neutral600,
          background: AppDesignSystem.surfaceWhite,
          border: AppDesignSystem.neutral200,
          foreground: AppDesignSystem.neutral900,
          glyph: LucideIcons.info,
        ),
    };

    final titleStyle = AppDesignSystem.labelLarge.copyWith(
      color: tokens.foreground,
      fontWeight: AppDesignSystem.semiBold,
    );
    final descriptionStyle = AppDesignSystem.bodySmall.copyWith(
      color: AppDesignSystem.neutral500,
    );

    // Compact leading-icon + text layout used as the toast's `title` slot so we
    // get a status glyph the default ShadToast layout doesn't provide.
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppDesignSystem.spacing2XS),
          decoration: BoxDecoration(
            color: tokens.icon.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull),
          ),
          child: Icon(
            tokens.glyph,
            size: AppDesignSystem.iconSizeSM,
            color: tokens.icon,
          ),
        ),
        const SizedBox(width: AppDesignSystem.spacingSM),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: titleStyle),
              if (description != null && description.isNotEmpty) ...[
                const SizedBox(height: AppDesignSystem.spacing2XS),
                Text(description, style: descriptionStyle),
              ],
            ],
          ),
        ),
      ],
    );

    final commonArgs = (
      alignment: _toastAlignment,
      duration: _toastDuration,
      // Don't reserve space / show the hover close button on touch devices.
      showCloseIconOnlyWhenHovered: true,
      backgroundColor: tokens.background,
      border: ShadBorder.all(color: tokens.border, width: 1),
      radius: BorderRadius.circular(AppDesignSystem.radiusLG),
      shadows: AppDesignSystem.shadowLG,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesignSystem.spacingMD,
        vertical: AppDesignSystem.spacingSM,
      ),
      // Size to content + cap width so short messages stay compact.
      mainAxisSize: MainAxisSize.min,
      constraints: const BoxConstraints(maxWidth: 380),
    );

    // The destructive variant carries shadcn's semantic styling; we still
    // override colors via tokens above for the clean light-mode look.
    if (variant == AppToastVariant.error) {
      return ShadToast.destructive(
        alignment: commonArgs.alignment,
        duration: commonArgs.duration,
        showCloseIconOnlyWhenHovered: commonArgs.showCloseIconOnlyWhenHovered,
        backgroundColor: commonArgs.backgroundColor,
        border: commonArgs.border,
        radius: commonArgs.radius,
        shadows: commonArgs.shadows,
        padding: commonArgs.padding,
        mainAxisSize: commonArgs.mainAxisSize,
        constraints: commonArgs.constraints,
        title: content,
      );
    }

    return ShadToast(
      alignment: commonArgs.alignment,
      duration: commonArgs.duration,
      showCloseIconOnlyWhenHovered: commonArgs.showCloseIconOnlyWhenHovered,
      backgroundColor: commonArgs.backgroundColor,
      border: commonArgs.border,
      radius: commonArgs.radius,
      shadows: commonArgs.shadows,
      padding: commonArgs.padding,
      mainAxisSize: commonArgs.mainAxisSize,
      constraints: commonArgs.constraints,
      title: content,
    );
  }
}
