import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/nutrition_plan_model.dart';

/// Row actions surfaced from a [NutritionPlanCard]'s overflow menu.
enum NutritionPlanCardAction { setActive, edit, delete }

/// List row for a nutrition-plan summary: name, active badge, meal count (when
/// available — list summaries don't carry meals), a compact total-calories chip
/// (when the server provides totals) and an overflow menu with set-active /
/// edit / delete.
class NutritionPlanCard extends StatelessWidget {
  final NutritionPlanModel plan;
  final VoidCallback onTap;
  final ValueChanged<NutritionPlanCardAction> onAction;

  const NutritionPlanCard({
    super.key,
    required this.plan,
    required this.onTap,
    required this.onAction,
  });

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
              color: plan.isActive
                  ? AppDesignSystem.accentSurface
                  : AppDesignSystem.neutral100,
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
            ),
            child: Icon(
              Icons.restaurant_menu_outlined,
              size: AppDesignSystem.iconSizeSM.sp,
              color: plan.isActive
                  ? AppDesignSystem.accentDark
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
                    if (plan.mealCount > 0)
                      AppBadge(
                        text: 'plan_meals_count'.tr(args: ['${plan.mealCount}']),
                        variant: AppBadgeVariant.info,
                        size: AppBadgeSize.small,
                        icon: Icons.restaurant_outlined,
                      ),
                    if (plan.totalCalories > 0)
                      AppBadge(
                        text: 'macro_calories_kcal'.tr(
                          args: [_n(plan.totalCalories)],
                        ),
                        variant: AppBadgeVariant.warning,
                        size: AppBadgeSize.small,
                        icon: Icons.local_fire_department_outlined,
                      ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<NutritionPlanCardAction>(
            icon: Icon(
              Icons.more_vert,
              size: AppDesignSystem.iconSizeSM.sp,
              color: AppDesignSystem.neutral500,
            ),
            onSelected: onAction,
            itemBuilder: (context) => [
              if (!plan.isActive)
                PopupMenuItem(
                  value: NutritionPlanCardAction.setActive,
                  child: _MenuRow(
                    icon: Icons.flag_outlined,
                    label: 'set_active'.tr(),
                  ),
                ),
              PopupMenuItem(
                value: NutritionPlanCardAction.edit,
                child: _MenuRow(
                  icon: Icons.edit_outlined,
                  label: 'edit'.tr(),
                ),
              ),
              PopupMenuItem(
                value: NutritionPlanCardAction.delete,
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
