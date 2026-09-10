import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constant/app_design_system.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  final Color? iconColor;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDesignSystem.spacingXL.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container with subtle background
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: (iconColor ?? AppDesignSystem.neutral400).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60.sp,
                color: iconColor ?? AppDesignSystem.neutral400,
              ),
            ),
            SizedBox(height: AppDesignSystem.spacingXL.h),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppDesignSystem.h3.copyWith(
                color: AppDesignSystem.neutral800,
              ),
            ),
            SizedBox(height: AppDesignSystem.spacingXS.h),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppDesignSystem.bodyLarge.copyWith(
                color: AppDesignSystem.neutral500,
              ),
            ),

            // Action button (if provided)
            if (action != null) ...[
              SizedBox(height: AppDesignSystem.spacingXL.h),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
