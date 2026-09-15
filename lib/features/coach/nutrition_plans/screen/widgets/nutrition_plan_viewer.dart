import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/meal_item_model.dart';
import '../../data/model/meal_model.dart';
import '../../data/model/nutrition_plan_model.dart';
import 'serving_display.dart';

/// Read-only renderer for a full [NutritionPlanModel] tree: meals as cards and
/// food items as rows with their enriched name, portion and computed macros.
class NutritionPlanViewer extends StatelessWidget {
  final NutritionPlanModel plan;

  const NutritionPlanViewer({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    if (plan.meals.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppDesignSystem.spacing2XL.h),
        child: Column(
          children: [
            Icon(
              Icons.restaurant_menu_outlined,
              size: AppDesignSystem.iconSizeXL.sp,
              color: AppDesignSystem.neutral300,
            ),
            SizedBox(height: AppDesignSystem.spacingSM.h),
            Text(
              'no_meals_yet'.tr(),
              style: AppDesignSystem.bodyMedium.copyWith(
                color: AppDesignSystem.neutral500,
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final meal in plan.meals) _MealView(meal: meal)],
    );
  }
}

class _MealView extends StatelessWidget {
  final MealModel meal;

  const _MealView({required this.meal});

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: AppDesignSystem.spacingMD.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  meal.name,
                  style: AppDesignSystem.h6.copyWith(
                    color: AppDesignSystem.neutral900,
                  ),
                ),
              ),
              AppBadge(
                text: 'macro_calories_kcal'.tr(args: [_n(meal.totalCalories)]),
                variant: AppBadgeVariant.warning,
                size: AppBadgeSize.small,
                icon: Icons.local_fire_department_outlined,
              ),
            ],
          ),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          if (meal.items.isEmpty)
            Text(
              'no_items_in_meal'.tr(),
              style: AppDesignSystem.bodySmall.copyWith(
                color: AppDesignSystem.neutral400,
              ),
            )
          else
            for (final item in meal.items) _ItemView(item: item),
        ],
      ),
    );
  }
}

class _ItemView extends StatelessWidget {
  final MealItemModel item;

  const _ItemView({required this.item});

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDesignSystem.spacingXS.h),
      padding: EdgeInsets.all(AppDesignSystem.spacingSM.w),
      decoration: BoxDecoration(
        color: AppDesignSystem.neutral50,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
        border: Border.all(color: AppDesignSystem.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.foodName ?? 'meal_item_entry'.tr(),
                  style: AppDesignSystem.bodyMedium.copyWith(
                    color: AppDesignSystem.neutral900,
                    fontWeight: AppDesignSystem.semiBold,
                  ),
                ),
              ),
              Text(
                'macro_calories_kcal'.tr(args: [_n(item.calories)]),
                style: AppDesignSystem.labelMedium.copyWith(
                  color: AppDesignSystem.accentDark,
                  fontWeight: AppDesignSystem.semiBold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignSystem.spacing2XS.h),
          Text(
            ServingDisplay.full(item.quantity, item.servingSize, item.servingUnit),
            style: AppDesignSystem.bodySmall.copyWith(
              color: AppDesignSystem.neutral500,
            ),
          ),
          SizedBox(height: AppDesignSystem.spacing2XS.h),
          Wrap(
            spacing: AppDesignSystem.spacingXS.w,
            runSpacing: AppDesignSystem.spacing2XS.h,
            children: [
              AppBadge(
                text: 'macro_protein_short_g'.tr(args: [_n(item.proteinG)]),
                variant: AppBadgeVariant.info,
                size: AppBadgeSize.small,
              ),
              AppBadge(
                text: 'macro_carbs_short_g'.tr(args: [_n(item.carbsG)]),
                variant: AppBadgeVariant.warning,
                size: AppBadgeSize.small,
              ),
              AppBadge(
                text: 'macro_fat_short_g'.tr(args: [_n(item.fatG)]),
                variant: AppBadgeVariant.success,
                size: AppBadgeSize.small,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
