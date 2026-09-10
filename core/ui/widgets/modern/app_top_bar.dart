import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constant/app_design_system.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final PreferredSizeWidget? bottom;

  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppDesignSystem.surfaceWhite,
      foregroundColor: foregroundColor ?? AppDesignSystem.neutral900,
      elevation: elevation ?? 0,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      surfaceTintColor: Colors.transparent,
      leading: leading,
      centerTitle: centerTitle,
      title: subtitle != null
          ? Column(
              crossAxisAlignment: centerTitle
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppDesignSystem.h5.copyWith(
                    color: foregroundColor ?? AppDesignSystem.neutral900,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle!,
                  style: AppDesignSystem.bodySmall.copyWith(
                    color: (foregroundColor ?? AppDesignSystem.neutral900)
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            )
          : Text(
              title,
              style: AppDesignSystem.h5.copyWith(
                color: foregroundColor ?? AppDesignSystem.neutral900,
              ),
            ),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    (subtitle != null ? 64.h : 56.h) + (bottom?.preferredSize.height ?? 0),
  );
}
