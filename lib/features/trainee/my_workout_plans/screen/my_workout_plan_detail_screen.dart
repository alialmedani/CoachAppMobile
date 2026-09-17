import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/constant/app_icons/app_icons.dart';
import 'package:coachappmobile/core/ui/widgets/app_icon.dart';
import 'package:coachappmobile/core/ui/widgets/apex/duotone_hero.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_day_model.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_exercise_model.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_plan_model.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/my_workout_plan_cubit.dart';

/// Read-only Apex view of one of the trainee's workout plans: a duotone hero
/// with a stat strip, then each training day as a card with its exercises on a
/// numbered spine (the Today-circuit language). Trainee-only — the shared coach
/// [PlanViewer] is left untouched.
class MyWorkoutPlanDetailScreen extends StatelessWidget {
  final String planId;

  const MyWorkoutPlanDetailScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyWorkoutPlanCubit>();
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceCanvas,
      appBar: AppTopBar(title: 'workout_plan_details'.tr()),
      body: GetModel<WorkoutPlanModel>(
        useCaseCallBack: () => cubit.fetchMyWorkoutPlanById(planId),
        modelBuilder: (plan) {
          final exerciseCount =
              plan.days.fold<int>(0, (s, d) => s + d.exercises.length);
          final todayWd = DateTime.now().weekday % 7; // Sun=0..Sat=6
          return SingleChildScrollView(
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
                                  'workout_plan'.tr().toUpperCase(),
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
                          _AccentTile(icon: AppIcons.barbell),
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
                            value: '${plan.dayCount}',
                            label: 'days'.tr(),
                          ),
                          SizedBox(width: AppDesignSystem.spacingSM.w),
                          _StatCell(
                            value: '$exerciseCount',
                            label: 'exercises'.tr(),
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
                _SectionLabel(icon: AppIcons.today, title: 'workout_days'.tr()),
                SizedBox(height: AppDesignSystem.spacingSM.h),
                if (plan.days.isEmpty)
                  _EmptyNote(
                    icon: AppIcons.today,
                    text: 'no_days_yet'.tr(),
                  )
                else
                  for (final day in plan.days)
                    _DayCard(
                      day: day,
                      isToday: day.scheduledDay?.value == todayWd,
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// Day card + exercise spine
// ============================================================================

class _DayCard extends StatelessWidget {
  final WorkoutDayModel day;
  final bool isToday;

  const _DayCard({required this.day, required this.isToday});

  @override
  Widget build(BuildContext context) {
    final ex = [...day.exercises]..sort((a, b) => a.order.compareTo(b.order));
    return Container(
      margin: EdgeInsets.only(bottom: AppDesignSystem.spacingMD.h),
      padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
      decoration: BoxDecoration(
        color: AppDesignSystem.surfaceRaised,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusLG.r),
        border: Border.all(
          color: isToday
              ? AppDesignSystem.primaryColor.withValues(alpha: 0.4)
              : AppDesignSystem.borderColor,
        ),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: AppDesignSystem.primaryColor.withValues(alpha: 0.12),
                  blurRadius: 16,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  day.name.trim().isNotEmpty ? day.name : 'workout_day'.tr(),
                  style: AppDesignSystem.h6
                      .copyWith(color: AppDesignSystem.textPrimary),
                ),
              ),
              if (isToday) ...[
                _TodayChip(),
                SizedBox(width: AppDesignSystem.spacingXS.w),
              ],
              AppBadge(
                text: day.scheduledDay != null
                    ? day.scheduledDay!.labelKey.tr()
                    : 'unscheduled'.tr(),
                variant: day.scheduledDay != null
                    ? AppBadgeVariant.info
                    : AppBadgeVariant.neutral,
                size: AppBadgeSize.small,
              ),
            ],
          ),
          SizedBox(height: AppDesignSystem.spacingMD.h),
          if (ex.isEmpty)
            Text(
              'no_exercises_in_day'.tr(),
              style: AppDesignSystem.bodySmall
                  .copyWith(color: AppDesignSystem.textFaint),
            )
          else
            _Spine(exercises: ex),
        ],
      ),
    );
  }
}

class _Spine extends StatelessWidget {
  final List<WorkoutExerciseModel> exercises;
  const _Spine({required this.exercises});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Rail (trailing edge — right in RTL).
        PositionedDirectional(
          top: 12.h,
          bottom: 12.h,
          end: 9.w,
          width: 2,
          child: Container(color: AppDesignSystem.borderColor),
        ),
        Column(
          children: [
            for (var i = 0; i < exercises.length; i++)
              _ExerciseRow(
                exercise: exercises[i],
                index: i + 1,
                first: i == 0,
              ),
          ],
        ),
      ],
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final WorkoutExerciseModel exercise;
  final int index;
  final bool first;

  const _ExerciseRow({
    required this.exercise,
    required this.index,
    required this.first,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDesignSystem.spacingXS.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.exerciseName?.trim().isNotEmpty == true
                      ? exercise.exerciseName!
                      : 'exercise'.tr(),
                  style: AppDesignSystem.bodyMedium.copyWith(
                    color: AppDesignSystem.textPrimary,
                    fontWeight: AppDesignSystem.semiBold,
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacing2XS.h),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    _sub(exercise),
                    style: AppDesignSystem.labelMedium.copyWith(
                      color: AppDesignSystem.textMuted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                if ((exercise.notes ?? '').isNotEmpty) ...[
                  SizedBox(height: AppDesignSystem.spacing2XS.h),
                  Text(
                    exercise.notes!,
                    style: AppDesignSystem.bodySmall
                        .copyWith(color: AppDesignSystem.textFaint),
                  ),
                ],
              ],
            ),
          ),
          if (exercise.weightKg != null) ...[
            SizedBox(width: AppDesignSystem.spacingSM.w),
            Text(
              '${_trim(exercise.weightKg!)} ${'unit_kg'.tr()}',
              style: AppDesignSystem.labelLarge.copyWith(
                color: AppDesignSystem.primaryStrong,
                fontWeight: AppDesignSystem.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
          SizedBox(width: AppDesignSystem.spacingMD.w),
          _Node(index: index, first: first),
        ],
      ),
    );
  }

  static String _sub(WorkoutExerciseModel e) {
    final b = StringBuffer('${e.sets}');
    if (e.reps != null && e.reps!.trim().isNotEmpty) {
      b.write(' × ${e.reps!.trim()}');
    }
    if (e.restSeconds != null && e.restSeconds! > 0) {
      b.write(' · ${e.restSeconds}s');
    }
    return b.toString();
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}

class _Node extends StatelessWidget {
  final int index;
  final bool first;
  const _Node({required this.index, required this.first});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      height: 20.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: first
            ? AppDesignSystem.primaryColor.withValues(alpha: 0.15)
            : AppDesignSystem.surfaceSunken,
        shape: BoxShape.circle,
        border: Border.all(
          color: first
              ? AppDesignSystem.primaryColor
              : AppDesignSystem.borderStrong,
          width: 1.5,
        ),
      ),
      child: Text(
        index.toString().padLeft(2, '0'),
        style: TextStyle(
          fontFamily: AppDesignSystem.fontFamily,
          fontSize: 9.sp,
          fontWeight: AppDesignSystem.bold,
          color: first
              ? AppDesignSystem.primaryStrong
              : AppDesignSystem.textMuted,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

// ============================================================================
// Shared bits (local)
// ============================================================================

class _TodayChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppDesignSystem.spacingXS.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppDesignSystem.primaryColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull.r),
      ),
      child: Text(
        'today_title'.tr(),
        style: TextStyle(
          fontFamily: AppDesignSystem.fontFamily,
          fontSize: AppDesignSystem.fontSizeXS.sp,
          fontWeight: AppDesignSystem.bold,
          color: AppDesignSystem.primaryStrong,
        ),
      ),
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
