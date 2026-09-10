import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../constant/app_design_system.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }

enum AppButtonSize { small, medium, large }

/// App button — public API is unchanged; internals are now backed by
/// [ShadButton] (shadcn_ui) instead of Material's ElevatedButton. All call
/// sites across the app keep working without edits.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool iconRight;
  final bool isLoading;
  final bool fullWidth;
  final double? customWidth;
  final double? customHeight;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconRight = false,
    this.isLoading = false,
    this.fullWidth = false,
    this.customWidth,
    this.customHeight,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final fg = textColor ?? _getForegroundColor();
    final width = fullWidth ? double.infinity : customWidth;
    final height = customHeight ?? _getHeight();

    final Widget label = isLoading
        ? SizedBox(
            width: _getIconSize(),
            height: _getIconSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Text(text, style: _getTextStyle());

    final Widget? leading = (icon != null && !iconRight && !isLoading)
        ? Icon(icon, size: _getIconSize())
        : null;
    final Widget? trailing = (icon != null && iconRight && !isLoading)
        ? Icon(icon, size: _getIconSize())
        : null;

    return _buildVariant(
      onPressed: enabled ? onPressed : null,
      width: width,
      height: height,
      foregroundColor: fg,
      leading: leading,
      trailing: trailing,
      child: label,
    );
  }

  Widget _buildVariant({
    required VoidCallback? onPressed,
    required double? width,
    required double height,
    required Color foregroundColor,
    required Widget? leading,
    required Widget? trailing,
    required Widget child,
  }) {
    switch (variant) {
      case AppButtonVariant.primary:
        return ShadButton(
          onPressed: onPressed,
          width: width,
          height: height,
          backgroundColor: backgroundColor ?? AppDesignSystem.primaryColor,
          foregroundColor: foregroundColor,
          leading: leading,
          trailing: trailing,
          child: child,
        );
      case AppButtonVariant.secondary:
        return ShadButton(
          onPressed: onPressed,
          width: width,
          height: height,
          backgroundColor: backgroundColor ?? AppDesignSystem.accentColor,
          foregroundColor: foregroundColor,
          leading: leading,
          trailing: trailing,
          child: child,
        );
      case AppButtonVariant.outline:
        return ShadButton.outline(
          onPressed: onPressed,
          width: width,
          height: height,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          leading: leading,
          trailing: trailing,
          child: child,
        );
      case AppButtonVariant.ghost:
        return ShadButton.ghost(
          onPressed: onPressed,
          width: width,
          height: height,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          leading: leading,
          trailing: trailing,
          child: child,
        );
      case AppButtonVariant.danger:
        return ShadButton.destructive(
          onPressed: onPressed,
          width: width,
          height: height,
          backgroundColor: backgroundColor ?? AppDesignSystem.errorColor,
          foregroundColor: foregroundColor,
          leading: leading,
          trailing: trailing,
          child: child,
        );
    }
  }

  Color _getForegroundColor() {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
      case AppButtonVariant.danger:
        return Colors.white;
      case AppButtonVariant.outline:
        return AppDesignSystem.primaryColor;
      case AppButtonVariant.ghost:
        return AppDesignSystem.neutral700;
    }
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 36.h;
      case AppButtonSize.medium:
        return 44.h;
      case AppButtonSize.large:
        return 52.h;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return AppDesignSystem.iconSizeXS.sp;
      case AppButtonSize.medium:
        return AppDesignSystem.iconSizeSM.sp;
      case AppButtonSize.large:
        return AppDesignSystem.iconSizeMD.sp;
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = size == AppButtonSize.small
        ? AppDesignSystem.labelMedium
        : size == AppButtonSize.medium
        ? AppDesignSystem.labelLarge
        : AppDesignSystem.h5;

    return baseStyle.copyWith(
      color: textColor ?? _getForegroundColor(),
      fontWeight: AppDesignSystem.semiBold,
    );
  }
}
