import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constant/app_design_system.dart';

enum AppBadgeVariant { primary, success, error, warning, info, neutral }

enum AppBadgeSize { small, medium, large }

class AppBadge extends StatelessWidget {
  final String text;
  final AppBadgeVariant variant;
  final AppBadgeSize size;
  final IconData? icon;
  final bool dot;

  const AppBadge({
    super.key,
    required this.text,
    this.variant = AppBadgeVariant.neutral,
    this.size = AppBadgeSize.medium,
    this.icon,
    this.dot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _getHorizontalPadding(),
        vertical: _getVerticalPadding(),
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull.r),
        border: Border.all(color: _getBorderColor(), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: _getDotSize(),
              height: _getDotSize(),
              decoration: BoxDecoration(
                color: _getForegroundColor(),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: AppDesignSystem.spacing2XS.w),
          ],
          if (icon != null && !dot) ...[
            Icon(icon, size: _getIconSize(), color: _getForegroundColor()),
            SizedBox(width: AppDesignSystem.spacing2XS.w),
          ],
          Text(text, style: _getTextStyle()),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case AppBadgeVariant.primary:
        return AppDesignSystem.primarySurface;
      case AppBadgeVariant.success:
        return AppDesignSystem.successSurface;
      case AppBadgeVariant.error:
        return AppDesignSystem.errorSurface;
      case AppBadgeVariant.warning:
        return AppDesignSystem.warningSurface;
      case AppBadgeVariant.info:
        return AppDesignSystem.infoSurface;
      case AppBadgeVariant.neutral:
        return AppDesignSystem.neutral100;
    }
  }

  Color _getBorderColor() {
    switch (variant) {
      case AppBadgeVariant.primary:
        return AppDesignSystem.primaryLight.withValues(alpha: 0.3);
      case AppBadgeVariant.success:
        return AppDesignSystem.successLight.withValues(alpha: 0.3);
      case AppBadgeVariant.error:
        return AppDesignSystem.errorLight.withValues(alpha: 0.3);
      case AppBadgeVariant.warning:
        return AppDesignSystem.warningLight.withValues(alpha: 0.3);
      case AppBadgeVariant.info:
        return AppDesignSystem.infoLight.withValues(alpha: 0.3);
      case AppBadgeVariant.neutral:
        return AppDesignSystem.neutral300;
    }
  }

  Color _getForegroundColor() {
    switch (variant) {
      case AppBadgeVariant.primary:
        return AppDesignSystem.primaryDark;
      case AppBadgeVariant.success:
        return AppDesignSystem.successColor;
      case AppBadgeVariant.error:
        return AppDesignSystem.errorColor;
      case AppBadgeVariant.warning:
        return AppDesignSystem.warningColor;
      case AppBadgeVariant.info:
        return AppDesignSystem.infoColor;
      case AppBadgeVariant.neutral:
        return AppDesignSystem.neutral700;
    }
  }

  double _getHorizontalPadding() {
    switch (size) {
      case AppBadgeSize.small:
        return AppDesignSystem.spacingXS.w;
      case AppBadgeSize.medium:
        return AppDesignSystem.spacingSM.w;
      case AppBadgeSize.large:
        return AppDesignSystem.spacingMD.w;
    }
  }

  double _getVerticalPadding() {
    switch (size) {
      case AppBadgeSize.small:
        return AppDesignSystem.spacing2XS.h;
      case AppBadgeSize.medium:
        return AppDesignSystem.spacing2XS.h;
      case AppBadgeSize.large:
        return AppDesignSystem.spacingXS.h;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppBadgeSize.small:
        return 12.sp;
      case AppBadgeSize.medium:
        return 14.sp;
      case AppBadgeSize.large:
        return 16.sp;
    }
  }

  double _getDotSize() {
    switch (size) {
      case AppBadgeSize.small:
        return 6.w;
      case AppBadgeSize.medium:
        return 8.w;
      case AppBadgeSize.large:
        return 10.w;
    }
  }

  TextStyle _getTextStyle() {
    final fontSize = size == AppBadgeSize.small
        ? AppDesignSystem.fontSizeXS
        : size == AppBadgeSize.medium
        ? AppDesignSystem.fontSizeSM
        : AppDesignSystem.fontSizeBase;

    return TextStyle(
      fontFamily: AppDesignSystem.fontFamily,
      fontSize: fontSize.sp,
      fontWeight: AppDesignSystem.semiBold,
      color: _getForegroundColor(),
      height: 1.2,
    );
  }
}
