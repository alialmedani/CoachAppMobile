import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Row actions surfaced from a [NutritionPlanTemplateCard]'s overflow menu.
enum NutritionPlanTemplateCardAction { useForTrainee, edit, delete }

/// List row for a nutrition-plan-template summary: name, meal count and a
/// compact total-calories chip (when available — list summaries carry neither
/// meals nor totals) and an overflow menu with use-for-trainee (clone) / edit /
/// delete, each gated by the caller's permission flags. Templates carry no
/// active state, so there is no badge.
class NutritionPlanTemplateCard extends StatelessWidget {
  final NutritionPlanModel template;
  final VoidCallback onTap;
  final ValueChanged<NutritionPlanTemplateCardAction> onAction;
  final bool canClone;
  final bool canEdit;
  final bool canDelete;

  const NutritionPlanTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onAction,
    this.canClone = false,
    this.canEdit = false,
    this.canDelete = false,
  });

  bool get _hasMenu => canClone || canEdit || canDelete;

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

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
              Icons.restaurant_menu_outlined,
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
                if (template.mealCount > 0 || template.totalCalories > 0) ...[
                  SizedBox(height: AppDesignSystem.spacingXS.h),
                  Wrap(
                    spacing: AppDesignSystem.spacingXS.w,
                    runSpacing: AppDesignSystem.spacing2XS.h,
                    children: [
                      if (template.mealCount > 0)
                        AppBadge(
                          text: 'plan_meals_count'.tr(
                            args: ['${template.mealCount}'],
                          ),
                          variant: AppBadgeVariant.info,
                          size: AppBadgeSize.small,
                          icon: Icons.restaurant_outlined,
                        ),
                      if (template.totalCalories > 0)
                        AppBadge(
                          text: 'macro_calories_kcal'.tr(
                            args: [_n(template.totalCalories)],
                          ),
                          variant: AppBadgeVariant.warning,
                          size: AppBadgeSize.small,
                          icon: Icons.local_fire_department_outlined,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (_hasMenu)
            PopupMenuButton<NutritionPlanTemplateCardAction>(
              icon: Icon(
                Icons.more_vert,
                size: AppDesignSystem.iconSizeSM.sp,
                color: AppDesignSystem.neutral500,
              ),
              onSelected: onAction,
              itemBuilder: (context) => [
                if (canClone)
                  PopupMenuItem(
                    value: NutritionPlanTemplateCardAction.useForTrainee,
                    child: _MenuRow(
                      icon: Icons.person_add_alt_outlined,
                      label: 'use_for_trainee'.tr(),
                    ),
                  ),
                if (canEdit)
                  PopupMenuItem(
                    value: NutritionPlanTemplateCardAction.edit,
                    child: _MenuRow(
                      icon: Icons.edit_outlined,
                      label: 'edit'.tr(),
                    ),
                  ),
                if (canDelete)
                  PopupMenuItem(
                    value: NutritionPlanTemplateCardAction.delete,
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
