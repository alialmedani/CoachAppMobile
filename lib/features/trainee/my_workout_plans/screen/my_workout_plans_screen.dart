import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/constant/app_icons/app_icons.dart';
import 'package:coachappmobile/core/di/injection.dart';
import 'package:coachappmobile/core/ui/widgets/app_icon.dart';
import 'package:coachappmobile/core/ui/widgets/apex/duotone_hero.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_enums.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_plan_model.dart';
import 'package:coachappmobile/features/trainee/workout_logs/cubit/workout_log_cubit.dart';
import 'package:coachappmobile/features/trainee/workout_logs/screen/workout_log_history_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/my_workout_plan_cubit.dart';
import 'my_workout_plan_detail_screen.dart';

/// Trainee's own workout plans (read-only), rebuilt on the Apex language: the
/// **active plan** is featured as a duotone card that previews the weekly split
/// (from a nested detail fetch); older plans collapse into one grouped panel.
class MyWorkoutPlansScreen extends StatelessWidget {
  /// Drops the top bar so the screen can sit directly inside the shell tab.
  final bool embedded;

  const MyWorkoutPlansScreen({super.key, this.embedded = false});

  void _openHistory(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => getIt<WorkoutLogCubit>(),
        child: const WorkoutLogHistoryScreen(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyWorkoutPlanCubit>();
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceCanvas,
      appBar: embedded
          ? null
          : AppTopBar(
              title: 'my_workout_plans'.tr(),
              actions: [
                IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: 'workout_history'.tr(),
                  color: AppDesignSystem.textMuted,
                  onPressed: () => _openHistory(context),
                ),
              ],
            ),
      body: GetModel<List<WorkoutPlanModel>>(
        useCaseCallBack: () => cubit.fetchMyWorkoutPlans(),
        modelBuilder: (plans) {
          if (plans.isEmpty) {
            return ListView(
              children: [
                SizedBox(height: AppDesignSystem.spacing4XL.h),
                AppEmptyState(
                  icon: Icons.fitness_center_outlined,
                  title: 'no_my_workout_plans'.tr(),
                  subtitle: 'no_my_workout_plans_subtitle'.tr(),
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
                  child: _FeaturedWorkoutCard(
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

  void _open(BuildContext context, MyWorkoutPlanCubit cubit, WorkoutPlanModel p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: MyWorkoutPlanDetailScreen(planId: p.id ?? ''),
        ),
      ),
    );
  }
}

// ============================================================================
// Featured active plan — duotone card previewing the weekly split
// ============================================================================

class _FeaturedWorkoutCard extends StatelessWidget {
  final WorkoutPlanModel summary;
  final VoidCallback onTap;

  const _FeaturedWorkoutCard({required this.summary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyWorkoutPlanCubit>();
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
                  _AccentTile(icon: AppIcons.barbell),
                ],
              ),
              // Weekly split + counts, from a nested detail fetch.
              GetModel<WorkoutPlanModel>(
                useCaseCallBack: () =>
                    cubit.fetchMyWorkoutPlanById(summary.id ?? ''),
                loadingWidget: const _StripPlaceholder(),
                errorWidget: const SizedBox.shrink(),
                modelBuilder: (detail) => _WeeklyStripStats(plan: detail),
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

class _WeeklyStripStats extends StatelessWidget {
  final WorkoutPlanModel plan;
  const _WeeklyStripStats({required this.plan});

  @override
  Widget build(BuildContext context) {
    final scheduled = plan.days
        .map((d) => d.scheduledDay)
        .whereType<Weekday>()
        .map((w) => w.value)
        .toSet();
    final exerciseCount =
        plan.days.fold<int>(0, (sum, d) => sum + d.exercises.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: AppDesignSystem.spacingMD.h),
        Row(
          children: [
            for (final wd in Weekday.values)
              Expanded(
                child: _DayDot(
                  letter: _letter(wd),
                  on: scheduled.contains(wd.value),
                ),
              ),
          ],
        ),
        SizedBox(height: AppDesignSystem.spacingMD.h),
        Text(
          '${'plan_days_per_week'.tr(args: ['${scheduled.length}'])} · ${'exercises_count'.tr(args: ['$exerciseCount'])}',
          style: AppDesignSystem.labelMedium.copyWith(
            color: AppDesignSystem.textMuted,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  static String _letter(Weekday wd) => switch (wd) {
    Weekday.sunday => 'S',
    Weekday.monday => 'M',
    Weekday.tuesday => 'T',
    Weekday.wednesday => 'W',
    Weekday.thursday => 'T',
    Weekday.friday => 'F',
    Weekday.saturday => 'S',
  };
}

class _DayDot extends StatelessWidget {
  final String letter;
  final bool on;
  const _DayDot({required this.letter, required this.on});

  @override
  Widget build(BuildContext context) {
    final color = on ? AppDesignSystem.primaryColor : AppDesignSystem.textFaint;
    return Column(
      children: [
        Text(
          letter,
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: AppDesignSystem.fontSizeXS.sp,
            fontWeight: AppDesignSystem.bold,
            color: on ? AppDesignSystem.primaryStrong : AppDesignSystem.textFaint,
          ),
        ),
        SizedBox(height: AppDesignSystem.spacingXS.h),
        Container(
          height: 5.h,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: on ? color : AppDesignSystem.surfaceSunken,
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull.r),
            boxShadow: on
                ? [
                    BoxShadow(
                      color: AppDesignSystem.primaryColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        ),
      ],
    );
  }
}

class _StripPlaceholder extends StatelessWidget {
  const _StripPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppDesignSystem.spacingMD.h),
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Container(
                height: 5.h,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  color: AppDesignSystem.surfaceSunken,
                  borderRadius:
                      BorderRadius.circular(AppDesignSystem.radiusFull.r),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// Previous plans — grouped panel
// ============================================================================

class _PreviousPanel extends StatelessWidget {
  final List<WorkoutPlanModel> plans;
  final void Function(WorkoutPlanModel) onTap;

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
  final WorkoutPlanModel plan;
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
                child: AppIcon(AppIcons.barbell,
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
// Shared bits
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
