import 'package:coachappmobile/core/boilerplate/get_model/cubits/get_model_cubit.dart';
import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/classes/cashe_helper.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/constant/app_icons/app_icons.dart';
import 'package:coachappmobile/core/di/injection.dart';
import 'package:coachappmobile/core/ui/widgets/app_icon.dart';
import 'package:coachappmobile/core/ui/widgets/apex/duotone_hero.dart';
import 'package:coachappmobile/core/ui/widgets/apex/gauge_meter.dart';
import 'package:coachappmobile/core/ui/widgets/apex/workout_spine.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/tracking/data/model/trainee_note_model.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_day_model.dart';
import 'package:coachappmobile/features/trainee/my_notes/cubit/my_notes_cubit.dart';
import 'package:coachappmobile/features/trainee/my_notes/data/repository/my_notes_repository.dart';
import 'package:coachappmobile/features/trainee/my_notes/screen/my_notes_screen.dart';
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
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/my_today_cubit.dart';
import '../data/model/my_today_model.dart';
import '../data/model/nutrition_adherence_model.dart';

/// The trainee's daily home, rebuilt on the Apex language: a duotone hero with
/// the readiness/completion **Gauge**, today's workout as a **Spine** circuit,
/// and a macro **equalizer**. Still actionable — logs today's workout (from-day)
/// and nutrition (from-plan), then refetches so state + adherence update.
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
      backgroundColor: AppDesignSystem.surfaceCanvas,
      appBar: widget.embedded ? null : AppTopBar(title: 'today_title'.tr()),
      body: GetModel<MyTodayModel>(
        onCubitCreated: (c) => _today = c,
        useCaseCallBack: () => today.fetchToday(),
        modelBuilder: (model) => SingleChildScrollView(
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
              _HeroBanner(today: model),
              SizedBox(height: AppDesignSystem.spacingXL.h),
              // Surfaces a new coach note here so the trainee doesn't have to dig
              // into Profile → Coach notes to discover it. Renders nothing (incl.
              // spacing) when there's no unseen note.
              const _CoachNoteCard(),
              _WorkoutSection(
                today: model,
                onLog: () => _logWorkout(model),
                onView: () => _viewWorkout(model),
              ),
              SizedBox(height: AppDesignSystem.spacingXL.h),
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
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Hero — duotone banner + completion gauge
// ============================================================================

/// Whether the trainee has a concrete workout to do today.
bool _hasWorkoutToday(MyTodayModel t) =>
    t.hasActiveWorkoutPlan && !t.isRestDay && t.scheduledWorkoutDays.isNotEmpty;

class _HeroBanner extends StatelessWidget {
  final MyTodayModel today;
  const _HeroBanner({required this.today});

  /// Honest completion metric from real state: average of "workout logged?"
  /// (when there's a session today) and nutrition adherence (server-computed
  /// overallPercent). Null when there are no active plans to score.
  double? _dayScore() {
    final parts = <double>[];
    if (_hasWorkoutToday(today)) {
      parts.add(today.alreadyLoggedWorkoutToday ? 1.0 : 0.0);
    }
    final a = today.nutritionAdherence;
    if (today.hasActiveNutritionPlan) {
      final pct = a.overallPercent ?? a.caloriesPercent ?? 0;
      parts.add((pct / 100).clamp(0.0, 1.0));
    }
    if (parts.isEmpty) return null;
    return parts.reduce((x, y) => x + y) / parts.length;
  }

  String _statusKey(double s) => s >= 0.8
      ? 'status_great'
      : s >= 0.4
      ? 'status_on_track'
      : 'status_get_started';

  @override
  Widget build(BuildContext context) {
    final score = _dayScore();

    // No active plans at all → a calm fallback hero without a gauge.
    if (score == null) {
      return DuotoneHero(
        ghostText: 'today_title'.tr(),
        child: Row(
          children: [
            AppIcon(AppIcons.today,
                size: AppDesignSystem.iconSizeLG,
                color: AppDesignSystem.primaryStrong),
            SizedBox(width: AppDesignSystem.spacingMD.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('today_title'.tr(),
                      style: AppDesignSystem.h4
                          .copyWith(color: AppDesignSystem.textPrimary)),
                  SizedBox(height: AppDesignSystem.spacing2XS.h),
                  Text('no_active_workout_plan_subtitle'.tr(),
                      style: AppDesignSystem.bodySmall
                          .copyWith(color: AppDesignSystem.textMuted)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final workout = _hasWorkoutToday(today);
    final day = workout ? today.scheduledWorkoutDays.first : null;
    final title = workout
        ? (day!.name.trim().isNotEmpty ? day.name : 'todays_workout'.tr())
        : (today.isRestDay ? 'rest_day'.tr() : 'todays_nutrition'.tr());
    final subtitle = workout
        ? 'exercises_count'.tr(args: ['${day!.exercises.length}'])
        : (today.isRestDay ? 'rest_day_subtitle'.tr() : '');

    return DuotoneHero(
      ghostText: workout ? title : 'today_title'.tr(),
      showPlate: false,
      child: Row(
        children: [
          GaugeMeter(
            value: score,
            size: 108.w,
            caption: _statusKey(score).tr(),
          ),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'today_title'.tr().toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: AppDesignSystem.fontSizeSM.sp,
                    fontWeight: AppDesignSystem.bold,
                    letterSpacing: 1.5,
                    color: AppDesignSystem.primaryStrong,
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacing2XS.h),
                Text(
                  title,
                  style: AppDesignSystem.h4.copyWith(
                    color: AppDesignSystem.textPrimary,
                    fontWeight: AppDesignSystem.extraBold,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppDesignSystem.bodySmall
                        .copyWith(color: AppDesignSystem.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Workout — the Spine circuit
// ============================================================================

class _WorkoutSection extends StatelessWidget {
  final MyTodayModel today;
  final VoidCallback onLog;
  final VoidCallback onView;

  const _WorkoutSection({
    required this.today,
    required this.onLog,
    required this.onView,
  });

  List<SpineNodeData> _nodes(WorkoutDayModel day, bool logged) {
    final ex = [...day.exercises]..sort((a, b) => a.order.compareTo(b.order));
    return [
      for (var i = 0; i < ex.length; i++)
        SpineNodeData(
          title: ex[i].exerciseName?.trim().isNotEmpty == true
              ? ex[i].exerciseName!
              : 'exercise'.tr(),
          subtitle: _sub(ex[i].sets, ex[i].reps, ex[i].restSeconds),
          indexLabel: (i + 1).toString().padLeft(2, '0'),
          state: logged
              ? SpineNodeState.done
              : (i == 0 ? SpineNodeState.current : SpineNodeState.upcoming),
          pipsTotal: ex[i].sets.clamp(0, 6),
          pipsDone: logged ? ex[i].sets.clamp(0, 6) : 0,
        ),
    ];
  }

  String _sub(int sets, String? reps, int? rest) {
    final b = StringBuffer('$sets');
    if (reps != null && reps.trim().isNotEmpty) b.write(' × ${reps.trim()}');
    if (rest != null && rest > 0) b.write(' · ${rest}s');
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (!today.hasActiveWorkoutPlan) {
      return _InfoCard(
        icon: AppIcons.barbell,
        title: 'no_active_workout_plan'.tr(),
        subtitle: 'no_active_workout_plan_subtitle'.tr(),
      );
    }
    if (today.isRestDay) {
      return _InfoCard(
        icon: AppIcons.timer,
        title: 'rest_day'.tr(),
        subtitle: 'rest_day_subtitle'.tr(),
        tint: AppDesignSystem.infoColor,
      );
    }
    if (today.scheduledWorkoutDays.isEmpty) {
      return _InfoCard(
        icon: AppIcons.today,
        title: 'nothing_scheduled_today'.tr(),
        subtitle: 'nothing_scheduled_today_subtitle'.tr(),
      );
    }

    final day = today.scheduledWorkoutDays.first;
    final logged = today.alreadyLoggedWorkoutToday;
    final total = day.exercises.length;
    final done = logged ? total : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            AppIcon(AppIcons.barbell,
                size: AppDesignSystem.iconSizeSM,
                color: AppDesignSystem.primaryStrong),
            SizedBox(width: AppDesignSystem.spacingXS.w),
            Expanded(
              child: Text(
                'workout_circuit'.tr(),
                style: AppDesignSystem.h6
                    .copyWith(color: AppDesignSystem.textPrimary),
              ),
            ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '$done / $total',
                style: AppDesignSystem.labelMedium.copyWith(
                  fontFamily: AppDesignSystem.fontFamily,
                  color: AppDesignSystem.textMuted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDesignSystem.spacingMD.h),
        WorkoutSpine(nodes: _nodes(day, logged)),
        SizedBox(height: AppDesignSystem.spacingSM.h),
        if (logged && today.latestWorkoutLogId != null)
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
            icon: Icons.bolt,
            fullWidth: true,
            onPressed: onLog,
          ),
      ],
    );
  }
}

// ============================================================================
// Nutrition — macro equalizer
// ============================================================================

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
        icon: AppIcons.nutrition,
        title: 'no_active_nutrition_plan'.tr(),
        subtitle: 'no_active_nutrition_plan_subtitle'.tr(),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MacroEqualizer(a: today.nutritionAdherence),
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
            icon: Icons.bolt,
            fullWidth: true,
            onPressed: onLog,
          ),
      ],
    );
  }
}

String _n(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

class _MacroEqualizer extends StatelessWidget {
  final NutritionAdherenceModel a;
  const _MacroEqualizer({required this.a});

  @override
  Widget build(BuildContext context) {
    final t = a.targetCalories;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('todays_intake'.tr(),
              style: AppDesignSystem.h6
                  .copyWith(color: AppDesignSystem.textPrimary)),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _n(a.consumedCalories),
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
                    t != null && t > 0
                        ? '/ ${_n(t)} ${'kcal'.tr()}'
                        : 'kcal'.tr(),
                    style: AppDesignSystem.bodySmall
                        .copyWith(color: AppDesignSystem.textFaint),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignSystem.spacingMD.h),
          Row(
            children: [
              _MacroColumn(
                label: 'protein'.tr(),
                value: a.consumedProteinG,
                target: a.targetProteinG,
                color: AppDesignSystem.infoColor,
              ),
              _MacroColumn(
                label: 'carbs'.tr(),
                value: a.consumedCarbsG,
                target: a.targetCarbsG,
                color: AppDesignSystem.warningColor,
              ),
              _MacroColumn(
                label: 'fat'.tr(),
                value: a.consumedFatG,
                target: a.targetFatG,
                color: AppDesignSystem.successColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroColumn extends StatelessWidget {
  final String label;
  final double value;
  final double? target;
  final Color color;

  const _MacroColumn({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final frac = (target != null && target! > 0)
        ? (value / target!).clamp(0.0, 1.0)
        : 0.0;
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppDesignSystem.spacing2XS.w),
        padding: EdgeInsets.symmetric(
          vertical: AppDesignSystem.spacingSM.h,
          horizontal: AppDesignSystem.spacingXS.w,
        ),
        decoration: BoxDecoration(
          color: AppDesignSystem.surfaceSunken,
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
        ),
        child: Column(
          children: [
            // vertical track (fills bottom-up to the consumed fraction)
            SizedBox(
              height: 64.h,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull.r),
                child: Container(
                  width: 8.w,
                  color: AppDesignSystem.borderColor,
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: frac,
                    child: Container(color: color),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppDesignSystem.spacingSM.h),
            Text(
              _n(value),
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: AppDesignSystem.fontSizeLG.sp,
                fontWeight: AppDesignSystem.bold,
                color: AppDesignSystem.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              label,
              style: AppDesignSystem.labelSmall
                  .copyWith(color: AppDesignSystem.textFaint),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Shared bits
// ============================================================================

/// Surfaces the coach's newest note on Today when it hasn't been opened yet
/// (tracked locally via [CacheHelper.lastSeenNoteId] — no backend read-flag).
/// Tapping opens the full notes list (which marks it seen), after which this
/// hides. Renders nothing — including its own spacing — when there's no unseen
/// note, so Today stays clean. Permanent access remains under Profile → Coach
/// notes.
class _CoachNoteCard extends StatefulWidget {
  const _CoachNoteCard();

  @override
  State<_CoachNoteCard> createState() => _CoachNoteCardState();
}

class _CoachNoteCardState extends State<_CoachNoteCard> {
  TraineeNoteModel? _latest;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await MyNotesRepository().getRecentRequest();
    if (!mounted) return;
    setState(() {
      _loaded = true;
      if (result.hasDataOnly) {
        final notes = result.data ?? const <TraineeNoteModel>[];
        _latest = notes.isNotEmpty ? notes.first : null;
      }
    });
  }

  bool get _isNew {
    final n = _latest;
    if (n == null || (n.id ?? '').isEmpty) return false;
    return n.id != CacheHelper.lastSeenNoteId;
  }

  Future<void> _open() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<MyNotesCubit>(),
          child: const MyNotesScreen(),
        ),
      ),
    );
    // Opening the list marks the newest note as seen → re-evaluate and hide.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || !_isNew) return const SizedBox.shrink();
    final note = _latest!;
    return Column(
      children: [
        AppCard(
          onTap: _open,
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppDesignSystem.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
                ),
                child: Icon(
                  Icons.sticky_note_2_outlined,
                  size: AppDesignSystem.iconSizeSM.sp,
                  color: AppDesignSystem.primaryStrong,
                ),
              ),
              SizedBox(width: AppDesignSystem.spacingMD.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 7.w,
                          height: 7.w,
                          decoration: BoxDecoration(
                            color: AppDesignSystem.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: AppDesignSystem.spacingXS.w),
                        Expanded(
                          child: Text(
                            'new_coach_note'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppDesignSystem.labelMedium.copyWith(
                              color: AppDesignSystem.primaryStrong,
                              fontWeight: AppDesignSystem.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDesignSystem.spacing2XS.h),
                    Text(
                      note.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppDesignSystem.bodySmall.copyWith(
                        color: AppDesignSystem.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: AppDesignSystem.iconSizeSM.sp,
                color: AppDesignSystem.textFaint,
              ),
            ],
          ),
        ),
        SizedBox(height: AppDesignSystem.spacingXL.h),
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
            style: AppDesignSystem.h5
                .copyWith(color: AppDesignSystem.textPrimary),
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
  final String icon;
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
    final color = tint ?? AppDesignSystem.primaryStrong;
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
            child: AppIcon(icon, size: AppDesignSystem.iconSizeSM, color: color),
          ),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppDesignSystem.bodyLarge.copyWith(
                    color: AppDesignSystem.textPrimary,
                    fontWeight: AppDesignSystem.semiBold,
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacing2XS.h),
                Text(
                  subtitle,
                  style: AppDesignSystem.bodySmall
                      .copyWith(color: AppDesignSystem.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
