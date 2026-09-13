import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/exercise_model.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final VoidCallback onTap;

  const ExerciseCard({super.key, required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: EdgeInsets.only(bottom: AppDesignSystem.spacingSM.h),
      padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: exercise.isActive
                  ? AppDesignSystem.primarySurface
                  : AppDesignSystem.neutral100,
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
            ),
            child: Icon(
              Icons.fitness_center,
              size: AppDesignSystem.iconSizeSM.sp,
              color: exercise.isActive
                  ? AppDesignSystem.primaryDark
                  : AppDesignSystem.neutral400,
            ),
          ),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppDesignSystem.h6.copyWith(
                    color: AppDesignSystem.neutral900,
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacingXS.h),
                Wrap(
                  spacing: AppDesignSystem.spacingXS.w,
                  runSpacing: AppDesignSystem.spacing2XS.h,
                  children: [
                    AppBadge(
                      text: exercise.targetMuscle.labelKey.tr(),
                      variant: AppBadgeVariant.info,
                      size: AppBadgeSize.small,
                    ),
                    AppBadge(
                      text: exercise.equipment.labelKey.tr(),
                      variant: AppBadgeVariant.neutral,
                      size: AppBadgeSize.small,
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
