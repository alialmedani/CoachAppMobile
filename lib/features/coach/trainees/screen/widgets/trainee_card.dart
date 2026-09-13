import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/trainee_model.dart';

/// A single trainee row in the coach's trainees list.
class TraineeCard extends StatelessWidget {
  final TraineeModel trainee;
  final VoidCallback onTap;

  const TraineeCard({super.key, required this.trainee, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: EdgeInsets.only(bottom: AppDesignSystem.spacingSM.h),
      padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
      child: Row(
        children: [
          _Avatar(initial: trainee.initial, active: trainee.isActive),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trainee.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppDesignSystem.h6.copyWith(
                    color: AppDesignSystem.neutral900,
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacing2XS.h),
                Text(
                  '@${trainee.userName ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppDesignSystem.bodySmall.copyWith(
                    color: AppDesignSystem.neutral500,
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacingXS.h),
                Wrap(
                  spacing: AppDesignSystem.spacingXS.w,
                  runSpacing: AppDesignSystem.spacing2XS.h,
                  children: [
                    AppBadge(
                      text: trainee.goal.labelKey.tr(),
                      variant: AppBadgeVariant.info,
                      size: AppBadgeSize.small,
                      icon: Icons.flag_outlined,
                    ),
                    AppBadge(
                      text: (trainee.isActive ? 'active' : 'inactive').tr(),
                      variant: trainee.isActive
                          ? AppBadgeVariant.success
                          : AppBadgeVariant.neutral,
                      size: AppBadgeSize.small,
                      dot: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppDesignSystem.neutral400,
            size: AppDesignSystem.iconSizeMD.sp,
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initial;
  final bool active;

  const _Avatar({required this.initial, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active
            ? AppDesignSystem.primarySurface
            : AppDesignSystem.neutral100,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: AppDesignSystem.h5.copyWith(
          color: active
              ? AppDesignSystem.primaryDark
              : AppDesignSystem.neutral500,
        ),
      ),
    );
  }
}
