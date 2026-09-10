import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constant/app_colors/app_colors.dart';
import '../../../constant/app_design_system.dart';

enum AppCardVariant { elevated, outlined, flat }

class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? borderRadius;
  final bool withBorder;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.withBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? EdgeInsets.all(AppDesignSystem.spacingMD.w),
      decoration: BoxDecoration(
        color:
            backgroundColor ?? Theme.of(context).colorScheme.appCard,
        borderRadius: BorderRadius.circular(
          borderRadius?.r ?? AppDesignSystem.radiusLG.r,
        ),
        boxShadow: _getShadow(),
        border: _getBorder(context),
      ),
      child: child,
    );

    if (onTap != null) {
      return Container(
        margin: margin,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              borderRadius?.r ?? AppDesignSystem.radiusLG.r,
            ),
            child: content,
          ),
        ),
      );
    }

    return Container(margin: margin, child: content);
  }

  List<BoxShadow>? _getShadow() {
    if (variant == AppCardVariant.elevated) {
      return AppDesignSystem.shadowMD;
    }
    return null;
  }

  Border? _getBorder(BuildContext context) {
    if (variant == AppCardVariant.outlined || withBorder) {
      return Border.all(
        color: borderColor ?? Theme.of(context).colorScheme.appBorder,
        width: 1,
      );
    }
    return null;
  }
}
