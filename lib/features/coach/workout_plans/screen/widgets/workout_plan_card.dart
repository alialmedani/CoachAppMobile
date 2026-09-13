import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/workout_plan_model.dart';

/// Row actions surfaced from a [WorkoutPlanCard]'s overflow menu.
enum WorkoutPlanCardAction { setActive, edit, delete }

/// List row for a workout-plan summary: name, active badge, day count (when
/// available — list summaries don't carry days) and an overflow menu with
/// set-active / edit / delete.
class WorkoutPlanCard extends StatelessWidget {
  final WorkoutPlanModel plan;
  final VoidCallback onTap;
  final ValueChanged<WorkoutPlanCardAction> onAction;

  const WorkoutPlanCard({
    super.key,
    required this.plan,
    required this.onTap,
    required this.onAction,
  });

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
              color: plan.isActive
                  ? AppDesignSystem.primarySurface
                  : AppDesignSystem.neutral100,
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: AppDesignSystem.iconSizeSM.sp,
              color: plan.isActive
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
                  plan.name ?? '',
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
                      text: (plan.isActive ? 'active' : 'inactive').tr(),
                      variant: plan.isActive
                          ? AppBadgeVariant.success
                          : AppBadgeVariant.neutral,
                      size: AppBadgeSize.small,
                      dot: true,
                    ),
                    if (plan.dayCount > 0)
                      AppBadge(
                        text: 'plan_days_count'.tr(args: ['${plan.dayCount}']),
                        variant: AppBadgeVariant.info,
                        size: AppBadgeSize.small,
                        icon: Icons.event_note_outlined,
                      ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<WorkoutPlanCardAction>(
            icon: Icon(
              Icons.more_vert,
              size: AppDesignSystem.iconSizeSM.sp,
              color: AppDesignSystem.neutral500,
            ),
            onSelected: onAction,
            itemBuilder: (context) => [
              if (!plan.isActive)
                PopupMenuItem(
                  value: WorkoutPlanCardAction.setActive,
                  child: _MenuRow(
                    icon: Icons.flag_outlined,
                    label: 'set_active'.tr(),
                  ),
                ),
              PopupMenuItem(
                value: WorkoutPlanCardAction.edit,
                child: _MenuRow(
                  icon: Icons.edit_outlined,
                  label: 'edit'.tr(),
                ),
              ),
              PopupMenuItem(
                value: WorkoutPlanCardAction.delete,
                child: _MenuRow(
                  icon: Icons.delete_outline,
                  label: 'delete'.tr(),
                  color: AppDesignSystem.errorColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MenuRow({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppDesignSystem.neutral700;
    return Row(
      children: [
        Icon(icon, size: AppDesignSystem.iconSizeSM.sp, color: c),
        SizedBox(width: AppDesignSystem.spacingSM.w),
        Text(label, style: AppDesignSystem.bodyMedium.copyWith(color: c)),
      ],
    );
  }
}
