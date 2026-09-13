import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/screen/widgets/macro_summary_card.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_plan_model.dart';
import 'package:coachappmobile/features/coach/workout_plans/screen/widgets/plan_viewer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/my_today_cubit.dart';
import '../data/model/my_today_model.dart';

/// The trainee's daily home. Composes today's scheduled workout (or rest-day /
/// no-plan state), whether it's already logged, the active nutrition plan and
/// the day's nutrition adherence — all for the device's local date.
///
/// Read-only for now; the "log this workout / nutrition" entry points arrive
/// with Phases 14–15 (workout/nutrition logging).
class TodayScreen extends StatelessWidget {
  final bool embedded;

  const TodayScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyTodayCubit>();
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: embedded ? null : AppTopBar(title: 'today_title'.tr()),
      body: GetModel<MyTodayModel>(
        useCaseCallBack: () => cubit.fetchToday(),
        modelBuilder: (today) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionHeader(
                title: 'todays_workout'.tr(),
                trailing: today.hasActiveWorkoutPlan && !today.isRestDay
                    ? _LoggedBadge(logged: today.alreadyLoggedWorkoutToday)
                    : null,
              ),
              SizedBox(height: AppDesignSystem.spacingSM.h),
              _WorkoutSection(today: today),
              SizedBox(height: AppDesignSystem.spacingLG.h),
              _SectionHeader(
                title: 'todays_nutrition'.tr(),
                trailing: today.hasActiveNutritionPlan
                    ? _LoggedBadge(logged: today.alreadyLoggedNutritionToday)
                    : null,
              ),
              SizedBox(height: AppDesignSystem.spacingSM.h),
              _NutritionSection(today: today),
              SizedBox(height: AppDesignSystem.spacingXL.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutSection extends StatelessWidget {
  final MyTodayModel today;

  const _WorkoutSection({required this.today});

  @override
  Widget build(BuildContext context) {
    if (!today.hasActiveWorkoutPlan) {
      return _InfoCard(
        icon: Icons.fitness_center_outlined,
        title: 'no_active_workout_plan'.tr(),
        subtitle: 'no_active_workout_plan_subtitle'.tr(),
      );
    }
    if (today.isRestDay) {
      return _InfoCard(
        icon: Icons.self_improvement_outlined,
        title: 'rest_day'.tr(),
        subtitle: 'rest_day_subtitle'.tr(),
        tint: AppDesignSystem.infoColor,
      );
    }
    if (today.scheduledWorkoutDays.isEmpty) {
      return _InfoCard(
        icon: Icons.event_available_outlined,
        title: 'nothing_scheduled_today'.tr(),
        subtitle: 'nothing_scheduled_today_subtitle'.tr(),
      );
    }
    // Reuse the read-only PlanViewer by wrapping today's scheduled days in a
    // lightweight plan.
    return PlanViewer(plan: WorkoutPlanModel(days: today.scheduledWorkoutDays));
  }
}

class _NutritionSection extends StatelessWidget {
  final MyTodayModel today;

  const _NutritionSection({required this.today});

  @override
  Widget build(BuildContext context) {
    if (!today.hasActiveNutritionPlan) {
      return _InfoCard(
        icon: Icons.restaurant_outlined,
        title: 'no_active_nutrition_plan'.tr(),
        subtitle: 'no_active_nutrition_plan_subtitle'.tr(),
      );
    }
    final a = today.nutritionAdherence;
    return MacroSummaryCard(
      calories: a.consumedCalories,
      proteinG: a.consumedProteinG,
      carbsG: a.consumedCarbsG,
      fatG: a.consumedFatG,
      targetCalories: a.targetCalories,
      targetProteinG: a.targetProteinG,
      targetCarbsG: a.targetCarbsG,
      targetFatG: a.targetFatG,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppDesignSystem.h5.copyWith(
              color: AppDesignSystem.neutral900,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _LoggedBadge extends StatelessWidget {
  final bool logged;

  const _LoggedBadge({required this.logged});

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      text: (logged ? 'logged_today' : 'not_logged_yet').tr(),
      variant: logged ? AppBadgeVariant.success : AppBadgeVariant.neutral,
      size: AppBadgeSize.small,
      icon: logged ? Icons.check_circle_outline : Icons.schedule_outlined,
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? tint;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final color = tint ?? AppDesignSystem.neutral400;
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppDesignSystem.iconSizeSM.sp,
            ),
          ),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppDesignSystem.bodyLarge.copyWith(
                    color: AppDesignSystem.neutral900,
                    fontWeight: AppDesignSystem.semiBold,
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacing2XS.h),
                Text(
                  subtitle,
                  style: AppDesignSystem.bodySmall.copyWith(
                    color: AppDesignSystem.neutral500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
