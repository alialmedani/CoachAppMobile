import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/constant/app_icons/app_icons.dart';
import 'package:coachappmobile/core/di/injection.dart';
import 'package:coachappmobile/core/ui/widgets/app_icon.dart';
import 'package:coachappmobile/core/ui/widgets/apex/duotone_hero.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';
import 'package:coachappmobile/features/trainee/nutrition_logs/cubit/nutrition_log_cubit.dart';
import 'package:coachappmobile/features/trainee/nutrition_logs/screen/nutrition_log_history_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/my_nutrition_plan_cubit.dart';
import 'my_nutrition_plan_detail_screen.dart';

String _n(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

/// Trainee's own nutrition plans (read-only), rebuilt on the Apex language: the
/// **active plan** is featured as a duotone card that previews the daily
/// calories + macro split (from a nested detail fetch); older plans collapse
/// into one grouped panel.
class MyNutritionPlansScreen extends StatelessWidget {
  final bool embedded;

  const MyNutritionPlansScreen({super.key, this.embedded = false});

  void _openHistory(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => getIt<NutritionLogCubit>(),
        child: const NutritionLogHistoryScreen(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyNutritionPlanCubit>();
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceCanvas,
      appBar: embedded
          ? null
          : AppTopBar(
              title: 'my_nutrition_plans'.tr(),
              actions: [
                IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: 'nutrition_history'.tr(),
                  color: AppDesignSystem.textMuted,
                  onPressed: () => _openHistory(context),
                ),
              ],
            ),
      body: GetModel<List<NutritionPlanModel>>(
        useCaseCallBack: () => cubit.fetchMyNutritionPlans(),
        modelBuilder: (plans) {
          if (plans.isEmpty) {
            return ListView(
              children: [
                SizedBox(height: AppDesignSystem.spacing4XL.h),
                AppEmptyState(
                  icon: Icons.restaurant_outlined,
                  title: 'no_my_nutrition_plans'.tr(),
                  subtitle: 'no_my_nutrition_plans_subtitle'.tr(),
                  iconColor: AppDesignSystem.primaryColor,
                ),
              ],
            );
          }
          final active = plans.where((p) => p.isActive).toList();
          final previous = plans.where((p) => !p.isActive).toList();
          return ListView(
            padding: EdgeInsets.fromLTRB(
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacingMD.h,
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacing4XL.h,
            ),
            children: [
              for (final p in active)
                Padding(
                  padding: EdgeInsets.only(bottom: AppDesignSystem.spacingMD.h),
                  child: _FeaturedNutritionCard(
                    summary: p,
                    onTap: () => _open(context, cubit, p),
                  ),
                ),
              if (previous.isNotEmpty) ...[
                SizedBox(height: AppDesignSystem.spacingXS.h),
                _SectionOverline(text: 'previous_plans'.tr()),
                SizedBox(height: AppDesignSystem.spacingSM.h),
                _PreviousPanel(
                  plans: previous,
                  onTap: (p) => _open(context, cubit, p),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _open(
      BuildContext context, MyNutritionPlanCubit cubit, NutritionPlanModel p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: MyNutritionPlanDetailScreen(planId: p.id ?? ''),
        ),
      ),
    );
  }
}

// ============================================================================
// Featured active plan — duotone card previewing calories + macro split
// ============================================================================

class _FeaturedNutritionCard extends StatelessWidget {
  final NutritionPlanModel summary;
  final VoidCallback onTap;

  const _FeaturedNutritionCard({required this.summary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyNutritionPlanCubit>();
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDesignSystem.radiusLG.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusLG.r),
        child: DuotoneHero(
          showPlate: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _ActiveLabel(),
                        SizedBox(height: AppDesignSystem.spacingXS.h),
                        Text(
                          summary.name ?? '',
                          style: AppDesignSystem.h4.copyWith(
                            color: AppDesignSystem.textPrimary,
                            fontWeight: AppDesignSystem.extraBold,
                          ),
                        ),
                        if ((summary.description ?? '').isNotEmpty) ...[
                          SizedBox(height: AppDesignSystem.spacing2XS.h),
                          Text(
                            summary.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppDesignSystem.bodySmall
                                .copyWith(color: AppDesignSystem.textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: AppDesignSystem.spacingSM.w),
                  _AccentTile(icon: AppIcons.nutrition),
                ],
              ),
              GetModel<NutritionPlanModel>(
                useCaseCallBack: () =>
                    cubit.fetchMyNutritionPlanById(summary.id ?? ''),
                loadingWidget: const _GlimpsePlaceholder(),
                errorWidget: const SizedBox.shrink(),
                modelBuilder: (detail) => _MacroGlimpse(plan: detail),
              ),
              SizedBox(height: AppDesignSystem.spacingMD.h),
              const _ViewFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroGlimpse extends StatelessWidget {
  final NutritionPlanModel plan;
  const _MacroGlimpse({required this.plan});

  @override
  Widget build(BuildContext context) {
    final p = plan.totalProteinG, c = plan.totalCarbsG, f = plan.totalFatG;
    final pc = p * 4, cc = c * 4, fc = f * 9;
    final tot = (pc + cc + fc);
    int flex(double x) => tot <= 0 ? 1 : (x / tot * 1000).round().clamp(1, 1000);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: AppDesignSystem.spacingMD.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _n(plan.totalCalories),
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: AppDesignSystem.fontSize3XL.sp,
                    fontWeight: AppDesignSystem.extraBold,
                    height: 1,
                    letterSpacing: -1,
                    color: AppDesignSystem.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'kcal_per_day'.tr(),
                  style: AppDesignSystem.labelSmall
                      .copyWith(color: AppDesignSystem.textFaint),
                ),
              ],
            ),
            SizedBox(width: AppDesignSystem.spacingLG.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDesignSystem.radiusFull.r),
                    child: Row(
                      children: [
                        Expanded(
                          flex: flex(pc),
                          child: Container(
                              height: 6.h, color: AppDesignSystem.infoColor),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          flex: flex(cc),
                          child: Container(
                              height: 6.h, color: AppDesignSystem.warningColor),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          flex: flex(fc),
                          child: Container(
                              height: 6.h, color: AppDesignSystem.successColor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppDesignSystem.spacingXS.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _MacroTag('macro_protein_short_g', p, AppDesignSystem.infoColor),
                      _MacroTag('macro_carbs_short_g', c, AppDesignSystem.warningColor),
                      _MacroTag('macro_fat_short_g', f, AppDesignSystem.successColor),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MacroTag extends StatelessWidget {
  final String key0;
  final double grams;
  final Color color;
  const _MacroTag(this.key0, this.grams, this.color);
  @override
  Widget build(BuildContext context) {
    return Text(
      key0.tr(args: [_n(grams)]),
      style: TextStyle(
        fontFamily: AppDesignSystem.fontFamily,
        fontSize: AppDesignSystem.fontSizeXS.sp,
        fontWeight: AppDesignSystem.bold,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

class _GlimpsePlaceholder extends StatelessWidget {
  const _GlimpsePlaceholder();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppDesignSystem.spacingMD.h),
      child: Container(
        height: 6.h,
        decoration: BoxDecoration(
          color: AppDesignSystem.surfaceSunken,
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull.r),
        ),
      ),
    );
  }
}

// ============================================================================
// Previous plans — grouped panel
// ============================================================================

class _PreviousPanel extends StatelessWidget {
  final List<NutritionPlanModel> plans;
  final void Function(NutritionPlanModel) onTap;

  const _PreviousPanel({required this.plans, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppDesignSystem.surfaceRaised,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusLG.r),
        border: Border.all(color: AppDesignSystem.borderColor),
      ),
      child: Column(
        children: [
          for (var i = 0; i < plans.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: AppDesignSystem.spacingMD.w,
                endIndent: AppDesignSystem.spacingMD.w,
                color: AppDesignSystem.borderColor,
              ),
            _PreviousRow(
              plan: plans[i],
              onTap: () => onTap(plans[i]),
              first: i == 0,
              last: i == plans.length - 1,
            ),
          ],
        ],
      ),
    );
  }
}

class _PreviousRow extends StatelessWidget {
  final NutritionPlanModel plan;
  final VoidCallback onTap;
  final bool first;
  final bool last;

  const _PreviousRow({
    required this.plan,
    required this.onTap,
    required this.first,
    required this.last,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.vertical(
      top: Radius.circular(first ? AppDesignSystem.radiusLG.r : 0),
      bottom: Radius.circular(last ? AppDesignSystem.radiusLG.r : 0),
    );
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppDesignSystem.surfaceSunken,
                  borderRadius:
                      BorderRadius.circular(AppDesignSystem.radiusMD.r),
                  border: Border.all(color: AppDesignSystem.borderColor),
                ),
                child: AppIcon(AppIcons.nutrition,
                    size: AppDesignSystem.iconSizeXS,
                    color: AppDesignSystem.textFaint),
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
                      style: AppDesignSystem.bodyMedium.copyWith(
                        color: AppDesignSystem.textPrimary,
                        fontWeight: AppDesignSystem.semiBold,
                      ),
                    ),
                    if ((plan.description ?? '').isNotEmpty) ...[
                      SizedBox(height: AppDesignSystem.spacing2XS.h),
                      Text(
                        plan.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppDesignSystem.bodySmall
                            .copyWith(color: AppDesignSystem.textFaint),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  size: AppDesignSystem.iconSizeSM.sp,
                  color: AppDesignSystem.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Shared bits (local)
// ============================================================================

class _ActiveLabel extends StatelessWidget {
  const _ActiveLabel();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(
            color: AppDesignSystem.successColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppDesignSystem.successColor.withValues(alpha: 0.4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        SizedBox(width: AppDesignSystem.spacingXS.w),
        Text(
          'active_plan'.tr().toUpperCase(),
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: AppDesignSystem.fontSizeXS.sp,
            fontWeight: AppDesignSystem.bold,
            letterSpacing: 1.5,
            color: AppDesignSystem.primaryStrong,
          ),
        ),
      ],
    );
  }
}

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

class _ViewFooter extends StatelessWidget {
  const _ViewFooter();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 1, color: AppDesignSystem.borderColor),
        SizedBox(height: AppDesignSystem.spacingSM.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'view_plan'.tr(),
              style: AppDesignSystem.labelLarge.copyWith(
                color: AppDesignSystem.primaryStrong,
                fontWeight: AppDesignSystem.bold,
              ),
            ),
            Icon(Icons.chevron_left,
                size: AppDesignSystem.iconSizeSM.sp,
                color: AppDesignSystem.primaryStrong),
          ],
        ),
      ],
    );
  }
}

class _SectionOverline extends StatelessWidget {
  final String text;
  const _SectionOverline({required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: AppDesignSystem.fontFamily,
        fontSize: AppDesignSystem.fontSizeXS.sp,
        fontWeight: AppDesignSystem.bold,
        letterSpacing: 1.5,
        color: AppDesignSystem.textFaint,
      ),
    );
  }
}
