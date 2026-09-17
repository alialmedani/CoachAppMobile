import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constant/app_colors/app_colors.dart';
import '../../../constant/app_design_system.dart';
import '../../shapes/chamfer.dart';

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

  /// When true the card uses the Apex signature chamfer (equipment-tag) shape
  /// instead of a rounded rectangle. Off by default — existing call sites are
  /// unaffected.
  final bool chamfer;
  final double? chamferCut;
  final Set<ChamferCorner>? chamferCorners;

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
    this.chamfer = false,
    this.chamferCut,
    this.chamferCorners,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? EdgeInsets.all(AppDesignSystem.spacingMD.w),
      decoration: chamfer
          ? ShapeDecoration(
              color: backgroundColor ?? Theme.of(context).colorScheme.appCard,
              shape: _chamferBorder(context),
              shadows: _getShadow(),
            )
          : BoxDecoration(
              color: backgroundColor ?? Theme.of(context).colorScheme.appCard,
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
            customBorder: chamfer ? _chamferBorder(context) : null,
            borderRadius: chamfer
                ? null
                : BorderRadius.circular(
                    borderRadius?.r ?? AppDesignSystem.radiusLG.r,
                  ),
            child: content,
          ),
        ),
      );
    }

    return Container(margin: margin, child: content);
  }

  ChamferBorder _chamferBorder(BuildContext context) => ChamferBorder(
    cut: (chamferCut ?? AppDesignSystem.radiusLG).r,
    corners: chamferCorners ?? kApexTagCorners,
    side: (variant == AppCardVariant.outlined || withBorder)
        ? BorderSide(
            color: borderColor ?? Theme.of(context).colorScheme.appBorder,
          )
        : BorderSide.none,
  );

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
