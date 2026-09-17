import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/constant/app_icons/app_icons.dart';
import 'package:coachappmobile/core/ui/widgets/app_icon.dart';
import 'package:coachappmobile/core/ui/widgets/apex/duotone_hero.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/meal_item_model.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/meal_model.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/screen/widgets/serving_display.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/my_nutrition_plan_cubit.dart';

String _n(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

/// Read-only Apex view of one of the trainee's nutrition plans: a duotone hero,
/// an Apex macro summary (plan totals vs targets), then meals as cards with
/// their food items + per-item macros. Trainee-only — the shared coach
/// [NutritionPlanViewer] / [MacroSummaryCard] are left untouched.
class MyNutritionPlanDetailScreen extends StatelessWidget {
  final String planId;

  const MyNutritionPlanDetailScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyNutritionPlanCubit>();
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceCanvas,
      appBar: AppTopBar(title: 'nutrition_plan_details'.tr()),
      body: GetModel<NutritionPlanModel>(
        useCaseCallBack: () => cubit.fetchMyNutritionPlanById(planId),
        modelBuilder: (plan) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            AppDesignSystem.spacingMD.w,
            AppDesignSystem.spacingMD.h,
            AppDesignSystem.spacingMD.w,
            AppDesignSystem.spacing3XL.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DuotoneHero(
                ghostText: plan.name,
                showPlate: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'nutrition_plan'.tr().toUpperCase(),
                                style: TextStyle(
                                  fontFamily: AppDesignSystem.fontFamily,
                                  fontSize: AppDesignSystem.fontSizeXS.sp,
                                  fontWeight: AppDesignSystem.bold,
                                  letterSpacing: 1.5,
                                  color: AppDesignSystem.primaryStrong,
                                ),
                              ),
                              SizedBox(height: AppDesignSystem.spacingXS.h),
                              Text(
                                plan.name ?? '',
                                style: AppDesignSystem.h4.copyWith(
                                  color: AppDesignSystem.textPrimary,
                                  fontWeight: AppDesignSystem.extraBold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: AppDesignSystem.spacingSM.w),
                        _AccentTile(icon: AppIcons.nutrition),
                      ],
                    ),
                    if ((plan.description ?? '').isNotEmpty) ...[
                      SizedBox(height: AppDesignSystem.spacingSM.h),
                      Text(
                        plan.description!,
                        style: AppDesignSystem.bodySmall.copyWith(
                          color: AppDesignSystem.textMuted,
                          height: 1.5,
                        ),
                      ),
                    ],
                    SizedBox(height: AppDesignSystem.spacingMD.h),
                    Row(
                      children: [
                        _StatCell(
                          value: '${plan.mealCount}',
                          label: 'meals'.tr(),
                        ),
                        SizedBox(width: AppDesignSystem.spacingSM.w),
                        _StatCell(
                          value: _n(plan.totalCalories),
                          label: 'kcal_per_day'.tr(),
                        ),
                        SizedBox(width: AppDesignSystem.spacingSM.w),
                        _StatCell(
                          value: plan.isActive ? '●' : '—',
                          label: (plan.isActive ? 'active' : 'inactive').tr(),
                          accent: plan.isActive
                              ? AppDesignSystem.successColor
                              : AppDesignSystem.textFaint,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDesignSystem.spacingLG.h),
              _MacroSummary(plan: plan),
              SizedBox(height: AppDesignSystem.spacingLG.h),
              _SectionLabel(icon: AppIcons.nutrition, title: 'meals'.tr()),
              SizedBox(height: AppDesignSystem.spacingSM.h),
              if (plan.meals.isEmpty)
                _EmptyNote(
                  icon: AppIcons.nutrition,
                  text: 'no_meals_yet'.tr(),
                )
              else
                for (final meal in plan.meals) _MealCard(meal: meal),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Macro summary — plan totals vs targets
// ============================================================================

class _MacroSummary extends StatelessWidget {
  final NutritionPlanModel plan;
  const _MacroSummary({required this.plan});

  @override
  Widget build(BuildContext context) {
    final target = plan.targetCalories;
    return Container(
      padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
      decoration: BoxDecoration(
        color: AppDesignSystem.surfaceRaised,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusLG.r),
        border: Border.all(color: AppDesignSystem.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (plan.hasTargets ? 'daily_total_vs_target' : 'daily_total').tr(),
            style: AppDesignSystem.h6.copyWith(color: AppDesignSystem.textPrimary),
          ),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _n(plan.totalCalories),
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: AppDesignSystem.fontSize4XL.sp,
                  fontWeight: AppDesignSystem.extraBold,
                  height: 1,
                  letterSpacing: -1,
                  color: AppDesignSystem.accentColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              SizedBox(width: AppDesignSystem.spacingXS.w),
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    target != null && target > 0
                        ? '/ ${_n(target)} ${'kcal'.tr()}'
                        : 'kcal'.tr(),
                    style: AppDesignSystem.bodySmall
                        .copyWith(color: AppDesignSystem.textFaint),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignSystem.spacingMD.h),
          _Bar(
            label: 'protein'.tr(),
            value: plan.totalProteinG,
            target: plan.targetProteinG,
            color: AppDesignSystem.infoColor,
          ),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          _Bar(
            label: 'carbs'.tr(),
            value: plan.totalCarbsG,
            target: plan.targetCarbsG,
            color: AppDesignSystem.warningColor,
          ),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          _Bar(
            label: 'fat'.tr(),
            value: plan.totalFatG,
            target: plan.targetFatG,
            color: AppDesignSystem.successColor,
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double value;
  final double? target;
  final Color color;

  const _Bar({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final frac =
        (target != null && target! > 0) ? (value / target!).clamp(0.0, 1.0) : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 76.w,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppDesignSystem.labelMedium
                .copyWith(color: AppDesignSystem.textMuted),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull.r),
            child: LinearProgressIndicator(
              value: frac,
              minHeight: 7.h,
              backgroundColor: AppDesignSystem.surfaceSunken,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        SizedBox(width: AppDesignSystem.spacingSM.w),
        SizedBox(
          width: 62.w,
          // Force LTR so "total / target" doesn't visually swap in Arabic.
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              target != null && target! > 0
                  ? '${_n(value)} / ${_n(target!)}'
                  : '${_n(value)} ${'unit_g'.tr()}',
              textAlign: TextAlign.end,
              style: AppDesignSystem.labelSmall.copyWith(
                color: AppDesignSystem.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Meal card
// ============================================================================

class _MealCard extends StatelessWidget {
  final MealModel meal;
  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDesignSystem.spacingMD.h),
      padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
      decoration: BoxDecoration(
        color: AppDesignSystem.surfaceRaised,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusLG.r),
        border: Border.all(color: AppDesignSystem.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  meal.name.trim().isNotEmpty ? meal.name : 'meal'.tr(),
                  style: AppDesignSystem.h6
                      .copyWith(color: AppDesignSystem.textPrimary),
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
          SizedBox(height: AppDesignSystem.spacingXS.h),
          if (meal.items.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: AppDesignSystem.spacingXS.h),
              child: Text(
                'no_items_in_meal'.tr(),
                style: AppDesignSystem.bodySmall
                    .copyWith(color: AppDesignSystem.textFaint),
              ),
            )
          else
            for (final item in meal.items) _ItemRow(item: item),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final MealItemModel item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppDesignSystem.spacingSM.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppDesignSystem.borderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.foodName?.trim().isNotEmpty == true
                      ? item.foodName!
                      : 'meal_item_entry'.tr(),
                  style: AppDesignSystem.bodyMedium.copyWith(
                    color: AppDesignSystem.textPrimary,
                    fontWeight: AppDesignSystem.semiBold,
                  ),
                ),
              ),
              SizedBox(width: AppDesignSystem.spacingSM.w),
              Text(
                'macro_calories_kcal'.tr(args: [_n(item.calories)]),
                style: AppDesignSystem.labelMedium.copyWith(
                  color: AppDesignSystem.accentColor,
                  fontWeight: AppDesignSystem.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignSystem.spacing2XS.h),
          Text(
            ServingDisplay.full(item.quantity, item.servingSize, item.servingUnit),
            style: AppDesignSystem.labelSmall.copyWith(
              color: AppDesignSystem.textFaint,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(height: AppDesignSystem.spacingXS.h),
          Row(
            children: [
              _MacroChip('macro_protein_short_g', item.proteinG,
                  AppDesignSystem.infoColor),
              SizedBox(width: AppDesignSystem.spacingXS.w),
              _MacroChip('macro_carbs_short_g', item.carbsG,
                  AppDesignSystem.warningColor),
              SizedBox(width: AppDesignSystem.spacingXS.w),
              _MacroChip('macro_fat_short_g', item.fatG,
                  AppDesignSystem.successColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String key0;
  final double grams;
  final Color color;
  const _MacroChip(this.key0, this.grams, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppDesignSystem.spacingXS.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusSM.r),
      ),
      child: Text(
        key0.tr(args: [_n(grams)]),
        style: TextStyle(
          fontFamily: AppDesignSystem.fontFamily,
          fontSize: AppDesignSystem.fontSizeXS.sp,
          fontWeight: AppDesignSystem.bold,
          color: color,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

// ============================================================================
// Shared bits (local)
// ============================================================================

class _AccentTile extends StatelessWidget {
  final String icon;
  const _AccentTile({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46.w,
      height: 46.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppDesignSystem.primaryColor.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
        border: Border.all(
            color: AppDesignSystem.primaryColor.withValues(alpha: 0.28)),
      ),
      child: AppIcon(icon,
          size: AppDesignSystem.iconSizeMD, color: AppDesignSystem.primaryStrong),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color? accent;
  const _StatCell({required this.value, required this.label, this.accent});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppDesignSystem.spacingSM.h,
          horizontal: AppDesignSystem.spacingXS.w,
        ),
        decoration: BoxDecoration(
          color: AppDesignSystem.surfaceCanvas.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
          border: Border.all(color: AppDesignSystem.borderColor),
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: AppDesignSystem.fontSizeXL.sp,
                fontWeight: AppDesignSystem.extraBold,
                height: 1,
                color: accent ?? AppDesignSystem.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            SizedBox(height: AppDesignSystem.spacing2XS.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppDesignSystem.labelSmall
                  .copyWith(color: AppDesignSystem.textFaint),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String icon;
  final String title;
  const _SectionLabel({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIcon(icon,
            size: AppDesignSystem.iconSizeSM,
            color: AppDesignSystem.primaryStrong),
        SizedBox(width: AppDesignSystem.spacingXS.w),
        Text(
          title,
          style:
              AppDesignSystem.h6.copyWith(color: AppDesignSystem.textPrimary),
        ),
      ],
    );
  }
}

class _EmptyNote extends StatelessWidget {
  final String icon;
  final String text;
  const _EmptyNote({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppDesignSystem.spacing2XL.h),
      alignment: Alignment.center,
      child: Column(
        children: [
          AppIcon(icon,
              size: AppDesignSystem.iconSizeLG, color: AppDesignSystem.textFaint),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          Text(
            text,
            style: AppDesignSystem.bodyMedium
                .copyWith(color: AppDesignSystem.textMuted),
          ),
        ],
      ),
    );
  }
}
