import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constant/app_design_system.dart';
import 'app_button.dart';

/// Full-area error state for a **failed initial load**, with a Retry action.
///
/// Visually mirrors [AppEmptyState] but in the error accent, and is a plain
/// self-centering widget (NOT a Scaffold), so it drops into any screen body
/// without adding a second app bar. [message] is the (already-localized)
/// backend reason; [onRetry] re-runs the screen's existing fetch.
class AppErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorState({
    super.key,
    this.message,
    this.onRetry,
    this.icon = Icons.cloud_off_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final detail = (message == null || message!.trim().isEmpty)
        ? 'something_went_wrong'.tr()
        : message!;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDesignSystem.spacingXL.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: AppDesignSystem.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 60.sp, color: AppDesignSystem.errorColor),
            ),
            SizedBox(height: AppDesignSystem.spacingXL.h),
            Text(
              'failed_to_load'.tr(),
              textAlign: TextAlign.center,
              style: AppDesignSystem.h3.copyWith(
                color: AppDesignSystem.neutral800,
              ),
            ),
            SizedBox(height: AppDesignSystem.spacingXS.h),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: AppDesignSystem.bodyLarge.copyWith(
                color: AppDesignSystem.neutral500,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppDesignSystem.spacingXL.h),
              AppButton(
                text: 'retry'.tr(),
                icon: Icons.refresh,
                variant: AppButtonVariant.outline,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
