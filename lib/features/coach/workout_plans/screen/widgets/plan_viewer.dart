import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/workout_day_model.dart';
import '../../data/model/workout_exercise_model.dart';
import '../../data/model/workout_plan_model.dart';

/// Read-only renderer for a full [WorkoutPlanModel] tree: days as cards with a
/// scheduled-day chip, and exercises as rows.
class PlanViewer extends StatelessWidget {
  final WorkoutPlanModel plan;

  const PlanViewer({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    if (plan.days.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppDesignSystem.spacing2XL.h),
        child: Column(
          children: [
            Icon(
              Icons.event_note_outlined,
              size: AppDesignSystem.iconSizeXL.sp,
              color: AppDesignSystem.neutral300,
            ),
            SizedBox(height: AppDesignSystem.spacingSM.h),
            Text(
              'no_days_yet'.tr(),
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
      children: [
        for (final day in plan.days) _DayView(day: day),
      ],
    );
  }
}

class _DayView extends StatelessWidget {
  final WorkoutDayModel day;

  const _DayView({required this.day});

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
                  day.name,
                  style: AppDesignSystem.h6.copyWith(
                    color: AppDesignSystem.neutral900,
                  ),
                ),
              ),
              AppBadge(
                text: day.scheduledDay != null
                    ? day.scheduledDay!.labelKey.tr()
                    : 'unscheduled'.tr(),
                variant: day.scheduledDay != null
                    ? AppBadgeVariant.info
                    : AppBadgeVariant.neutral,
                size: AppBadgeSize.small,
                icon: Icons.event_outlined,
              ),
            ],
          ),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          if (day.exercises.isEmpty)
            Text(
              'no_exercises_in_day'.tr(),
              style: AppDesignSystem.bodySmall.copyWith(
                color: AppDesignSystem.neutral400,
              ),
            )
          else
            for (final ex in day.exercises) _ExerciseView(exercise: ex),
        ],
      ),
    );
  }
}

class _ExerciseView extends StatelessWidget {
  final WorkoutExerciseModel exercise;

  const _ExerciseView({required this.exercise});

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
          Text(
            exercise.exerciseName ?? 'exercise_entry'.tr(),
            style: AppDesignSystem.bodyMedium.copyWith(
              color: AppDesignSystem.neutral900,
              fontWeight: AppDesignSystem.semiBold,
            ),
          ),
          SizedBox(height: AppDesignSystem.spacing2XS.h),
          Wrap(
            spacing: AppDesignSystem.spacingXS.w,
            runSpacing: AppDesignSystem.spacing2XS.h,
            children: _summaryChips(),
          ),
          if ((exercise.notes ?? '').isNotEmpty) ...[
            SizedBox(height: AppDesignSystem.spacing2XS.h),
            Text(
              exercise.notes!,
              style: AppDesignSystem.bodySmall.copyWith(
                color: AppDesignSystem.neutral500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _summaryChips() {
    final chips = <Widget>[];
    final reps = exercise.reps;
    chips.add(
      AppBadge(
        text: reps != null && reps.isNotEmpty
            ? 'sets_x_reps'.tr(args: ['${exercise.sets}', reps])
            : 'sets_count'.tr(args: ['${exercise.sets}']),
        variant: AppBadgeVariant.primary,
        size: AppBadgeSize.small,
      ),
    );
    if (exercise.weightKg != null) {
      chips.add(
        AppBadge(
          text: '${_trimNum(exercise.weightKg!)} ${'unit_kg'.tr()}',
          variant: AppBadgeVariant.neutral,
          size: AppBadgeSize.small,
        ),
      );
    }
    if (exercise.restSeconds != null) {
      chips.add(
        AppBadge(
          text: 'rest_value'.tr(args: ['${exercise.restSeconds}']),
          variant: AppBadgeVariant.neutral,
          size: AppBadgeSize.small,
        ),
      );
    }
    return chips;
  }

  static String _trimNum(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}
