import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_plan_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Row actions surfaced from a [WorkoutPlanTemplateCard]'s overflow menu.
enum WorkoutPlanTemplateCardAction { useForTrainee, edit, delete }

/// List row for a workout-plan-template summary: name, day count (when
/// available — list summaries don't carry days) and an overflow menu with
/// use-for-trainee (clone) / edit / delete, each gated by the caller's
/// permission flags. Templates carry no active state, so there is no badge.
class WorkoutPlanTemplateCard extends StatelessWidget {
  final WorkoutPlanModel template;
  final VoidCallback onTap;
  final ValueChanged<WorkoutPlanTemplateCardAction> onAction;
  final bool canClone;
  final bool canEdit;
  final bool canDelete;

  const WorkoutPlanTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onAction,
    this.canClone = false,
    this.canEdit = false,
    this.canDelete = false,
  });

  bool get _hasMenu => canClone || canEdit || canDelete;

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
              color: AppDesignSystem.neutral100,
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
            ),
            child: Icon(
              Icons.dashboard_customize_outlined,
              size: AppDesignSystem.iconSizeSM.sp,
              color: AppDesignSystem.primaryDark,
            ),
          ),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppDesignSystem.h6.copyWith(
                    color: AppDesignSystem.neutral900,
                  ),
                ),
                if (template.dayCount > 0) ...[
                  SizedBox(height: AppDesignSystem.spacingXS.h),
                  AppBadge(
                    text: 'plan_days_count'.tr(args: ['${template.dayCount}']),
                    variant: AppBadgeVariant.info,
                    size: AppBadgeSize.small,
                    icon: Icons.event_note_outlined,
                  ),
                ],
              ],
            ),
          ),
          if (_hasMenu)
            PopupMenuButton<WorkoutPlanTemplateCardAction>(
              icon: Icon(
                Icons.more_vert,
                size: AppDesignSystem.iconSizeSM.sp,
                color: AppDesignSystem.neutral500,
              ),
              onSelected: onAction,
              itemBuilder: (context) => [
                if (canClone)
                  PopupMenuItem(
                    value: WorkoutPlanTemplateCardAction.useForTrainee,
                    child: _MenuRow(
                      icon: Icons.person_add_alt_outlined,
                      label: 'use_for_trainee'.tr(),
                    ),
                  ),
                if (canEdit)
                  PopupMenuItem(
                    value: WorkoutPlanTemplateCardAction.edit,
                    child: _MenuRow(
                      icon: Icons.edit_outlined,
                      label: 'edit'.tr(),
                    ),
                  ),
                if (canDelete)
                  PopupMenuItem(
                    value: WorkoutPlanTemplateCardAction.delete,
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
