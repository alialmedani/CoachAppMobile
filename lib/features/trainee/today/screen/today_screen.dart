import 'package:coachappmobile/core/boilerplate/get_model/cubits/get_model_cubit.dart';
import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/screen/widgets/macro_summary_card.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_plan_model.dart';
import 'package:coachappmobile/features/coach/workout_plans/screen/widgets/plan_viewer.dart';
import 'package:coachappmobile/features/trainee/nutrition_logs/cubit/nutrition_log_cubit.dart';
import 'package:coachappmobile/features/trainee/nutrition_logs/data/model/nutrition_log_model.dart';
import 'package:coachappmobile/features/trainee/nutrition_logs/data/params/nutrition_log_params.dart';
import 'package:coachappmobile/features/trainee/nutrition_logs/screen/nutrition_log_editor_screen.dart';
import 'package:coachappmobile/features/trainee/nutrition_logs/screen/nutrition_log_view_screen.dart';
import 'package:coachappmobile/features/trainee/workout_logs/cubit/workout_log_cubit.dart';
import 'package:coachappmobile/features/trainee/workout_logs/data/model/workout_log_model.dart';
import 'package:coachappmobile/features/trainee/workout_logs/data/params/workout_log_params.dart';
import 'package:coachappmobile/features/trainee/workout_logs/screen/workout_log_editor_screen.dart';
import 'package:coachappmobile/features/trainee/workout_logs/screen/workout_log_view_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/my_today_cubit.dart';
import '../data/model/my_today_model.dart';

/// The trainee's daily home. Composes today's scheduled workout (or rest-day /
/// no-plan state), the active nutrition plan and the day's adherence — and is
/// **actionable**: it can log today's workout (from-day) and nutrition
/// (from-plan), then refetches so the logged state + adherence update.
class TodayScreen extends StatefulWidget {
  final bool embedded;

  const TodayScreen({super.key, this.embedded = false});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  GetModelCubit? _today;

  void _refresh() => _today?.getModel();

  void _snack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _showLoading() => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  // ---- workout ---------------------------------------------------------------
  Future<void> _logWorkout(MyTodayModel today) async {
    final day = today.scheduledWorkoutDays.isNotEmpty
        ? today.scheduledWorkoutDays.first
        : null;
    if (day == null || day.id == null) return;
    final cubit = context.read<WorkoutLogCubit>();
    // Open the editor on an UNSAVED draft built from the plan day; the log is
    // created (from-day) only when the trainee taps Save — backing out leaves
    // no phantom log.
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: WorkoutLogEditorScreen(
            log: WorkoutLogModel.draftFromDay(day),
            createFromDay: WorkoutLogFromDayParams(
              workoutDayId: day.id!,
              date: MyTodayCubit.localToday(),
            ),
          ),
        ),
      ),
    );
    if (saved == true) _refresh();
  }

  Future<void> _viewWorkout(MyTodayModel today) async {
    final id = today.latestWorkoutLogId;
    if (id == null) return;
    final cubit = context.read<WorkoutLogCubit>();
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: WorkoutLogViewScreen(logId: id),
        ),
      ),
    );
    if (changed == true) _refresh();
  }

  // ---- nutrition -------------------------------------------------------------
  Future<void> _logNutrition(MyTodayModel today) async {
    final plan = today.nutritionPlan;
    if (plan == null || plan.id == null) return;
    final cubit = context.read<NutritionLogCubit>();
    // Open the editor on an UNSAVED draft built from the plan; the log is
    // created (from-plan) only when the trainee taps Save — backing out leaves
    // no phantom log.
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: NutritionLogEditorScreen(
            log: NutritionLogModel.draftFromPlan(plan),
            createFromPlan: NutritionLogFromPlanParams(
              nutritionPlanId: plan.id!,
              date: MyTodayCubit.localToday(),
            ),
          ),
        ),
      ),
    );
    if (saved == true) _refresh();
  }

  Future<void> _viewNutrition(MyTodayModel today) async {
    final cubit = context.read<NutritionLogCubit>();
    // Today doesn't carry the nutrition log id, so resolve today's log by date.
    _showLoading();
    final result = await cubit.fetchLogsByDate(MyTodayCubit.localToday());
    if (!mounted) return;
    Navigator.pop(context);
    if (!result.hasDataOnly) {
      _snack(
        result.error ?? 'something_went_wrong'.tr(),
        AppDesignSystem.errorColor,
      );
      return;
    }
    final logs = result.data as List<NutritionLogModel>;
    if (logs.isEmpty || logs.first.id == null) {
      _snack('nutrition_log_not_found'.tr(), AppDesignSystem.neutral500);
      return;
    }
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: NutritionLogViewScreen(logId: logs.first.id!),
        ),
      ),
    );
    if (changed == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final today = context.read<MyTodayCubit>();
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: widget.embedded ? null : AppTopBar(title: 'today_title'.tr()),
      body: GetModel<MyTodayModel>(
        onCubitCreated: (c) => _today = c,
        useCaseCallBack: () => today.fetchToday(),
        modelBuilder: (model) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionHeader(
                title: 'todays_workout'.tr(),
                trailing: model.hasActiveWorkoutPlan && !model.isRestDay
                    ? _LoggedBadge(logged: model.alreadyLoggedWorkoutToday)
                    : null,
              ),
              SizedBox(height: AppDesignSystem.spacingSM.h),
              _WorkoutSection(
                today: model,
                onLog: () => _logWorkout(model),
                onView: () => _viewWorkout(model),
              ),
              SizedBox(height: AppDesignSystem.spacingLG.h),
              _SectionHeader(
                title: 'todays_nutrition'.tr(),
                trailing: model.hasActiveNutritionPlan
                    ? _LoggedBadge(logged: model.alreadyLoggedNutritionToday)
                    : null,
              ),
              SizedBox(height: AppDesignSystem.spacingSM.h),
              _NutritionSection(
                today: model,
                onLog: () => _logNutrition(model),
                onView: () => _viewNutrition(model),
              ),
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
  final VoidCallback onLog;
  final VoidCallback onView;

  const _WorkoutSection({
    required this.today,
    required this.onLog,
    required this.onView,
  });

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlanViewer(plan: WorkoutPlanModel(days: today.scheduledWorkoutDays)),
        SizedBox(height: AppDesignSystem.spacingSM.h),
        if (today.alreadyLoggedWorkoutToday && today.latestWorkoutLogId != null)
          AppButton(
            text: 'view_todays_workout'.tr(),
            icon: Icons.receipt_long_outlined,
            variant: AppButtonVariant.outline,
            fullWidth: true,
            onPressed: onView,
          )
        else
          AppButton(
            text: 'log_this_workout'.tr(),
            icon: Icons.playlist_add_check,
            fullWidth: true,
            onPressed: onLog,
          ),
      ],
    );
  }
}

class _NutritionSection extends StatelessWidget {
  final MyTodayModel today;
  final VoidCallback onLog;
  final VoidCallback onView;

  const _NutritionSection({
    required this.today,
    required this.onLog,
    required this.onView,
  });

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MacroSummaryCard(
          calories: a.consumedCalories,
          proteinG: a.consumedProteinG,
          carbsG: a.consumedCarbsG,
          fatG: a.consumedFatG,
          targetCalories: a.targetCalories,
          targetProteinG: a.targetProteinG,
          targetCarbsG: a.targetCarbsG,
          targetFatG: a.targetFatG,
        ),
        SizedBox(height: AppDesignSystem.spacingSM.h),
        if (today.alreadyLoggedNutritionToday)
          AppButton(
            text: 'view_todays_nutrition'.tr(),
            icon: Icons.receipt_long_outlined,
            variant: AppButtonVariant.outline,
            fullWidth: true,
            onPressed: onView,
          )
        else
          AppButton(
            text: 'log_nutrition'.tr(),
            icon: Icons.playlist_add_check,
            fullWidth: true,
            onPressed: onLog,
          ),
      ],
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
