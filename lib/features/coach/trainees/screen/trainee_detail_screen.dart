import 'package:coachappmobile/core/boilerplate/get_model/cubits/get_model_cubit.dart';
import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/constant/app_icons/app_icons.dart';
import 'package:coachappmobile/core/ui/shapes/chamfer.dart';
import 'package:coachappmobile/core/ui/widgets/app_icon.dart';
import 'package:coachappmobile/core/ui/widgets/apex/athlete_credential.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:coachappmobile/core/boilerplate/pagination/models/get_list_request.dart';
import 'package:coachappmobile/core/di/injection.dart';
import 'package:coachappmobile/features/auth/constants/coachapp_permissions.dart';
import 'package:coachappmobile/features/auth/cubit/session_cubit.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/cubit/nutrition_plan_cubit.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/params/get_nutrition_plan_list_input.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/repository/nutrition_plan_repository.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/screen/nutrition_plans_list_screen.dart';
import 'package:coachappmobile/features/coach/tracking/cubit/coach_dashboard_cubit.dart';
import 'package:coachappmobile/features/coach/tracking/cubit/coach_log_cubit.dart';
import 'package:coachappmobile/features/coach/tracking/cubit/notes_cubit.dart';
import 'package:coachappmobile/features/coach/tracking/cubit/progress_cubit.dart';
import 'package:coachappmobile/features/coach/tracking/screen/coach_dashboard_screen.dart';
import 'package:coachappmobile/features/coach/tracking/screen/coach_logs_screen.dart';
import 'package:coachappmobile/features/coach/tracking/screen/notes_screen.dart';
import 'package:coachappmobile/features/coach/tracking/screen/progress_screen.dart';
import 'package:coachappmobile/features/coach/workout_plans/cubit/workout_plan_cubit.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_plan_model.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/params/get_workout_plan_list_input.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/repository/workout_plan_repository.dart';
import 'package:coachappmobile/features/coach/workout_plans/screen/workout_plans_list_screen.dart';

import '../cubit/trainee_cubit.dart';
import '../data/model/trainee_model.dart';
import 'edit_trainee_screen.dart';
import 'widgets/reset_password_sheet.dart';

String _n(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

String _fmtDate(DateTime? d) {
  if (d == null) return '—';
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

int? _age(DateTime? birth) {
  if (birth == null) return null;
  final now = DateTime.now();
  var a = now.year - birth.year;
  if (now.month < birth.month ||
      (now.month == birth.month && now.day < birth.day)) {
    a--;
  }
  return a < 0 || a > 130 ? null : a;
}

/// The coach's view of a trainee, rebuilt as the Apex **Athlete Dossier**: the
/// same [AthleteCredential] the trainee sees on their own profile, an instrument
/// strip of physical stats, a spec-sheet detail grid, a chamfered **tracking
/// deck** (dashboard / logs / progress / notes — permission-gated), and a
/// **manage deck** (edit / reset password / deactivate). All coach actions,
/// navigation and permission gates are unchanged; this is a presentation pass.
class TraineeDetailScreen extends StatefulWidget {
  final String traineeId;

  const TraineeDetailScreen({super.key, required this.traineeId});

  @override
  State<TraineeDetailScreen> createState() => _TraineeDetailScreenState();
}

class _TraineeDetailScreenState extends State<TraineeDetailScreen>
    with SingleTickerProviderStateMixin {
  GetModelCubit? _getModel;
  bool _changed = false;

  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool _revealStarted = false;

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  void _startReveal() {
    if (_revealStarted) return;
    _revealStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reveal.forward();
    });
  }

  /// Staggered entrance: each section fades + rises, offset by its index.
  Widget _staggered(int i, Widget child) {
    const span = 0.6;
    final start = (i * 0.09).clamp(0.0, 0.4);
    return AnimatedBuilder(
      animation: _reveal,
      builder: (_, _) {
        final raw = ((_reveal.value - start) / span).clamp(0.0, 1.0);
        final t = Curves.easeOutCubic.transform(raw);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TraineeCubit>();
    // System/gesture back must carry `_changed` back to the list (like the
    // leading button does) so the list refreshes after an edit/reset/delete.
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _changed);
      },
      child: Scaffold(
        backgroundColor: AppDesignSystem.surfaceCanvas,
        appBar: AppTopBar(
          title: 'trainee_details'.tr(),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _changed),
          ),
        ),
        body: GetModel<TraineeModel>(
          onCubitCreated: (c) => _getModel = c,
          useCaseCallBack: () => cubit.fetchTraineeById(widget.traineeId),
          modelBuilder: (trainee) {
            _startReveal();
            final age = _age(trainee.birthDate);
            final session = context.read<SessionCubit>();
            final canPlans = session.can(CoachPermissions.workoutPlans) ||
                session.can(CoachPermissions.nutritionPlans);
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppDesignSystem.spacingMD.w,
                AppDesignSystem.spacingSM.h,
                AppDesignSystem.spacingMD.w,
                AppDesignSystem.spacing4XL.h,
              ),
              children: [
                _staggered(
                  0,
                  AthleteCredential(
                    overline: 'athlete_credential'.tr(),
                    name: trainee.fullName,
                    initial: trainee.initial,
                    athleteId:
                        'APX · ${(trainee.userName ?? trainee.initial).toUpperCase()}',
                    memberSince: trainee.creationTime != null
                        ? '${'member_since'.tr()} ${trainee.creationTime!.year}'
                        : 'member_since'.tr(),
                    ageLabel: age != null
                        ? 'years_old'.tr(args: ['$age'])
                        : null,
                    goalLabel: trainee.goal.labelKey.tr(),
                    active: trainee.isActive,
                    statusLabel: (trainee.isActive ? 'active' : 'inactive').tr(),
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacingLG.h),
                _staggered(1, _InstrumentStrip(trainee: trainee)),
                SizedBox(height: AppDesignSystem.spacingLG.h),
                _staggered(
                  2,
                  _SectionLabel(icon: AppIcons.profile, title: 'details'.tr()),
                ),
                SizedBox(height: AppDesignSystem.spacingSM.h),
                _staggered(3, _SpecGrid(trainee: trainee)),
                SizedBox(height: AppDesignSystem.spacingLG.h),
                if (canPlans) ...[
                  _staggered(
                    4,
                    _SectionLabel(icon: AppIcons.plans, title: 'plans'.tr()),
                  ),
                  SizedBox(height: AppDesignSystem.spacingSM.h),
                  _staggered(
                    5,
                    _PlansDeck(
                      traineeId: trainee.id ?? widget.traineeId,
                      traineeName: trainee.fullName,
                    ),
                  ),
                  SizedBox(height: AppDesignSystem.spacingLG.h),
                ],
                _staggered(
                  6,
                  _SectionLabel(icon: AppIcons.gauge, title: 'tracking'.tr()),
                ),
                SizedBox(height: AppDesignSystem.spacingSM.h),
                _staggered(7, _TrackingDeck(trainee: trainee)),
                SizedBox(height: AppDesignSystem.spacingLG.h),
                _staggered(
                  8,
                  _SectionLabel(icon: AppIcons.bolt, title: 'manage'.tr()),
                ),
                SizedBox(height: AppDesignSystem.spacingSM.h),
                _staggered(
                  9,
                  _ManageDeck(
                    onEdit: () => _edit(cubit, trainee),
                    onResetPassword: () => showResetPasswordSheet(
                      context,
                      cubit: cubit,
                      traineeId: trainee.id ?? widget.traineeId,
                      traineeName: trainee.fullName,
                    ),
                    onDelete: () => _confirmDelete(cubit, trainee),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _edit(TraineeCubit cubit, TraineeModel trainee) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: EditTraineeScreen(trainee: trainee),
        ),
      ),
    );
    if (result == true) {
      _changed = true;
      _getModel?.getModel();
    }
  }

  Future<void> _confirmDelete(TraineeCubit cubit, TraineeModel trainee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('deactivate_trainee'.tr()),
        content: Text('deactivate_trainee_confirm'.tr(args: [trainee.fullName])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: AppDesignSystem.errorColor,
            ),
            child: Text('deactivate'.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await cubit.deleteTrainee(trainee.id ?? widget.traineeId);
    if (!mounted) return;
    if (result.hasDataOnly) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('trainee_deactivated'.tr()),
          backgroundColor: AppDesignSystem.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'something_went_wrong'.tr()),
          backgroundColor: AppDesignSystem.errorColor,
        ),
      );
    }
  }
}

// ============================================================================
// Instrument strip — physical stats as three gauges' worth of numbers
// ============================================================================

class _InstrumentStrip extends StatelessWidget {
  final TraineeModel trainee;
  const _InstrumentStrip({required this.trainee});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InstrTile(
            value: trainee.heightCm,
            unit: 'unit_cm'.tr(),
            label: 'height'.tr(),
          ),
        ),
        SizedBox(width: AppDesignSystem.spacingSM.w),
        Expanded(
          child: _InstrTile(
            value: trainee.startWeightKg,
            unit: 'unit_kg'.tr(),
            label: 'starting'.tr(),
          ),
        ),
        SizedBox(width: AppDesignSystem.spacingSM.w),
        Expanded(
          child: _InstrTile(
            value: trainee.targetWeightKg,
            unit: 'unit_kg'.tr(),
            label: 'goal'.tr(),
          ),
        ),
      ],
    );
  }
}

class _InstrTile extends StatelessWidget {
  final double? value;
  final String unit;
  final String label;

  const _InstrTile({
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppDesignSystem.spacingMD.h,
        horizontal: AppDesignSystem.spacingSM.w,
      ),
      decoration: BoxDecoration(
        color: AppDesignSystem.surfaceSunken,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
        border: Border.all(color: AppDesignSystem.borderColor),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value != null ? _n(value!) : '—',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: AppDesignSystem.fontSize3XL.sp,
                    fontWeight: AppDesignSystem.extraBold,
                    height: 1,
                    letterSpacing: -0.5,
                    color: value != null
                        ? AppDesignSystem.textPrimary
                        : AppDesignSystem.textFaint,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (value != null) ...[
                  SizedBox(width: 2.w),
                  Text(
                    unit,
                    style: AppDesignSystem.labelSmall
                        .copyWith(color: AppDesignSystem.textFaint),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: AppDesignSystem.spacingXS.h),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: AppDesignSystem.fontSizeXS.sp,
              fontWeight: AppDesignSystem.bold,
              letterSpacing: 1,
              color: AppDesignSystem.textFaint,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Spec grid — the detail "spec sheet"
// ============================================================================

class _SpecGrid extends StatelessWidget {
  final TraineeModel trainee;
  const _SpecGrid({required this.trainee});

  @override
  Widget build(BuildContext context) {
    final p = trainee;
    final items = <_SpecData>[
      _SpecData(
        icon: AppIcon(AppIcons.target,
            size: AppDesignSystem.iconSizeXS,
            color: AppDesignSystem.primaryStrong),
        label: 'training_goal'.tr(),
        value: p.goal.labelKey.tr(),
      ),
      _SpecData(
        icon: AppIcon(AppIcons.profile,
            size: AppDesignSystem.iconSizeXS,
            color: AppDesignSystem.primaryStrong),
        label: 'gender'.tr(),
        value: p.gender.labelKey.tr(),
      ),
      _SpecData(
        icon: Icon(Icons.cake_outlined,
            size: AppDesignSystem.iconSizeXS.sp,
            color: AppDesignSystem.primaryStrong),
        label: 'birth_date'.tr(),
        value: _fmtDate(p.birthDate),
      ),
      _SpecData(
        icon: Icon(Icons.event_outlined,
            size: AppDesignSystem.iconSizeXS.sp,
            color: AppDesignSystem.primaryStrong),
        label: 'member_since'.tr(),
        value: _fmtDate(p.creationTime),
      ),
      _SpecData(
        icon: Icon(Icons.phone_outlined,
            size: AppDesignSystem.iconSizeXS.sp,
            color: AppDesignSystem.primaryStrong),
        label: 'phone'.tr(),
        value: (p.phoneNumber ?? '').isNotEmpty ? p.phoneNumber! : '—',
      ),
      _SpecData(
        icon: Icon(Icons.alternate_email_outlined,
            size: AppDesignSystem.iconSizeXS.sp,
            color: AppDesignSystem.primaryStrong),
        label: 'email'.tr(),
        value: (p.email ?? '').isNotEmpty ? p.email! : '—',
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < items.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: AppDesignSystem.spacingSM.h),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _SpecTile(data: items[i])),
                  SizedBox(width: AppDesignSystem.spacingSM.w),
                  if (i + 1 < items.length)
                    Expanded(child: _SpecTile(data: items[i + 1]))
                  else
                    const Expanded(child: SizedBox()),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SpecData {
  final Widget icon;
  final String label;
  final String value;

  _SpecData({required this.icon, required this.label, required this.value});
}

class _SpecTile extends StatelessWidget {
  final _SpecData data;
  const _SpecTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
      decoration: BoxDecoration(
        color: AppDesignSystem.surfaceRaised,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
        border: Border.all(color: AppDesignSystem.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: AppDesignSystem.primaryColor.withValues(alpha: 0.10),
              shape: const ChamferBorder(cut: 8),
            ),
            child: data.icon,
          ),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          Text(
            data.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: AppDesignSystem.fontSizeXS.sp,
              fontWeight: AppDesignSystem.bold,
              letterSpacing: 0.8,
              color: AppDesignSystem.textFaint,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppDesignSystem.bodyLarge.copyWith(
              color: AppDesignSystem.textPrimary,
              fontWeight: AppDesignSystem.semiBold,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Tracking deck — permission-gated entry points as chamfered tiles
// ============================================================================

/// Permission-gated entry points into this trainee's tracking surface. The
/// destinations, cubits and gates are identical to the previous list section;
/// only the presentation (a chamfered 2-up deck) changed.
class _TrackingDeck extends StatelessWidget {
  final TraineeModel trainee;
  const _TrackingDeck({required this.trainee});

  void _open(BuildContext context, Widget child) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => child));
  }

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionCubit>();
    final id = trainee.id ?? '';
    final name = trainee.fullName;
    final tiles = <Widget>[];

    if (session.can(CoachPermissions.tracking)) {
      tiles.add(
        _DeckTile(
          icon: AppIcon(AppIcons.gauge,
              size: AppDesignSystem.iconSizeSM,
              color: AppDesignSystem.primaryStrong),
          label: 'coach_dashboard'.tr(),
          onTap: () => _open(
            context,
            BlocProvider(
              create: (_) => getIt<CoachDashboardCubit>(),
              child: CoachDashboardScreen(traineeId: id, traineeName: name),
            ),
          ),
        ),
      );
      tiles.add(
        _DeckTile(
          icon: Icon(Icons.receipt_long_outlined,
              size: AppDesignSystem.iconSizeSM.sp,
              color: AppDesignSystem.primaryStrong),
          label: 'logs'.tr(),
          onTap: () => _open(
            context,
            BlocProvider(
              create: (_) => getIt<CoachLogCubit>(),
              child: CoachLogsScreen(traineeId: id, traineeName: name),
            ),
          ),
        ),
      );
    }
    if (session.can(CoachPermissions.progress)) {
      tiles.add(
        _DeckTile(
          icon: AppIcon(AppIcons.progress,
              size: AppDesignSystem.iconSizeSM,
              color: AppDesignSystem.primaryStrong),
          label: 'progress'.tr(),
          onTap: () => _open(
            context,
            BlocProvider(
              create: (_) => getIt<ProgressCubit>(),
              child: ProgressScreen(traineeId: id, traineeName: name),
            ),
          ),
        ),
      );
    }
    if (session.can(CoachPermissions.notes)) {
      tiles.add(
        _DeckTile(
          icon: Icon(Icons.sticky_note_2_outlined,
              size: AppDesignSystem.iconSizeSM.sp,
              color: AppDesignSystem.primaryStrong),
          label: 'notes'.tr(),
          onTap: () => _open(
            context,
            BlocProvider(
              create: (_) => getIt<NotesCubit>(),
              child: NotesScreen(traineeId: id, traineeName: name),
            ),
          ),
        ),
      );
    }

    if (tiles.isEmpty) return const SizedBox.shrink();
    return _DeckGrid(tiles: tiles);
  }
}

// ============================================================================
// Plans deck — the trainee's active workout + nutrition plan
// ============================================================================

enum _PlanKind { workout, nutrition }

/// Per-type cards showing this trainee's ACTIVE plan (fetched live). Each opens
/// the existing plan list — already SCOPED to the trainee — where the coach can
/// view/open/edit/set-active AND create a new plan with the trainee already
/// pre-selected (no global trainee picker). Permission-gated per type.
class _PlansDeck extends StatelessWidget {
  final String traineeId;
  final String traineeName;

  const _PlansDeck({required this.traineeId, required this.traineeName});

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionCubit>();
    final tiles = <Widget>[];
    if (session.can(CoachPermissions.workoutPlans)) {
      tiles.add(_ActivePlanTile(
        kind: _PlanKind.workout,
        traineeId: traineeId,
        traineeName: traineeName,
      ));
    }
    if (session.can(CoachPermissions.nutritionPlans)) {
      tiles.add(_ActivePlanTile(
        kind: _PlanKind.nutrition,
        traineeId: traineeId,
        traineeName: traineeName,
      ));
    }
    if (tiles.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) SizedBox(height: AppDesignSystem.spacingSM.h),
          tiles[i],
        ],
      ],
    );
  }
}

/// One plan-type card: shows the active plan's name (or a "no active plan"
/// hint) and opens the SCOPED plan list (view / open / edit / set-active /
/// create — all pre-scoped to this trainee). Re-reads the active plan on return.
class _ActivePlanTile extends StatefulWidget {
  final _PlanKind kind;
  final String traineeId;
  final String traineeName;

  const _ActivePlanTile({
    required this.kind,
    required this.traineeId,
    required this.traineeName,
  });

  @override
  State<_ActivePlanTile> createState() => _ActivePlanTileState();
}

class _ActivePlanTileState extends State<_ActivePlanTile> {
  String? _activeName;
  bool _loaded = false;

  bool get _isWorkout => widget.kind == _PlanKind.workout;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    String? name;
    if (_isWorkout) {
      final r = await WorkoutPlanRepository().getWorkoutPlanListRequest(
        params: GetWorkoutPlanListInput(
          traineeId: widget.traineeId,
          isActive: true,
          request: GetListRequest(skip: 0, take: 5),
        ),
      );
      if (r.hasDataOnly) {
        final list = r.data ?? const <WorkoutPlanModel>[];
        name = list.isNotEmpty ? list.first.name : null;
      }
    } else {
      final r = await NutritionPlanRepository().getNutritionPlanListRequest(
        params: GetNutritionPlanListInput(
          traineeId: widget.traineeId,
          isActive: true,
          request: GetListRequest(skip: 0, take: 5),
        ),
      );
      if (r.hasDataOnly) {
        final list = r.data ?? const <NutritionPlanModel>[];
        name = list.isNotEmpty ? list.first.name : null;
      }
    }
    if (!mounted) return;
    setState(() {
      _loaded = true;
      _activeName = name;
    });
  }

  Future<void> _open() async {
    final Widget screen = _isWorkout
        ? BlocProvider(
            create: (_) => getIt<WorkoutPlanCubit>(),
            child: WorkoutPlansListScreen(
              traineeId: widget.traineeId,
              traineeName: widget.traineeName,
            ),
          )
        : BlocProvider(
            create: (_) => getIt<NutritionPlanCubit>(),
            child: NutritionPlansListScreen(
              traineeId: widget.traineeId,
              traineeName: widget.traineeName,
            ),
          );
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    // A plan may have been created / activated / deleted — refresh the summary.
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final typeLabel = (_isWorkout ? 'workout_plan' : 'nutrition_plan').tr();
    final hasActive = _activeName != null;
    final subtitle = !_loaded
        ? '—'
        : (_activeName ??
            (_isWorkout ? 'no_active_workout_plan' : 'no_active_nutrition_plan')
                .tr());

    return Material(
      color: AppDesignSystem.surfaceRaised,
      shape: ChamferBorder(
        cut: 12,
        side: BorderSide(color: AppDesignSystem.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _open,
        child: Padding(
          padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: AppDesignSystem.primaryColor.withValues(alpha: 0.12),
                  shape: const ChamferBorder(cut: 10),
                ),
                child: AppIcon(
                  _isWorkout ? AppIcons.barbell : AppIcons.nutrition,
                  size: AppDesignSystem.iconSizeSM,
                  color: AppDesignSystem.primaryStrong,
                ),
              ),
              SizedBox(width: AppDesignSystem.spacingMD.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeLabel,
                      style: AppDesignSystem.labelLarge.copyWith(
                        color: AppDesignSystem.textPrimary,
                        fontWeight: AppDesignSystem.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppDesignSystem.bodySmall.copyWith(
                              color: hasActive
                                  ? AppDesignSystem.textMuted
                                  : AppDesignSystem.textFaint,
                            ),
                          ),
                        ),
                        if (hasActive) ...[
                          SizedBox(width: AppDesignSystem.spacingXS.w),
                          AppBadge(
                            text: 'active'.tr(),
                            variant: AppBadgeVariant.success,
                            size: AppBadgeSize.small,
                            dot: true,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppDesignSystem.spacingXS.w),
              Icon(
                Icons.chevron_right,
                size: AppDesignSystem.iconSizeSM.sp,
                color: AppDesignSystem.textFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Manage deck — coach actions
// ============================================================================

class _ManageDeck extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onResetPassword;
  final VoidCallback onDelete;

  const _ManageDeck({
    required this.onEdit,
    required this.onResetPassword,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DeckGrid(
          tiles: [
            _DeckTile(
              icon: Icon(Icons.edit_outlined,
                  size: AppDesignSystem.iconSizeSM.sp,
                  color: AppDesignSystem.primaryStrong),
              label: 'edit_profile'.tr(),
              onTap: onEdit,
            ),
            _DeckTile(
              icon: Icon(Icons.lock_reset_outlined,
                  size: AppDesignSystem.iconSizeSM.sp,
                  color: AppDesignSystem.primaryStrong),
              label: 'reset_password'.tr(),
              onTap: onResetPassword,
            ),
          ],
        ),
        SizedBox(height: AppDesignSystem.spacingSM.h),
        _DeckTile(
          icon: Icon(Icons.person_off_outlined,
              size: AppDesignSystem.iconSizeSM.sp,
              color: AppDesignSystem.errorColor),
          label: 'deactivate_trainee'.tr(),
          danger: true,
          fullWidth: true,
          onTap: onDelete,
        ),
      ],
    );
  }
}

// ============================================================================
// Deck primitives
// ============================================================================

/// Lays a list of [_DeckTile]s out as a 2-up chamfered grid with equal-height
/// rows.
class _DeckGrid extends StatelessWidget {
  final List<Widget> tiles;
  const _DeckGrid({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < tiles.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: AppDesignSystem.spacingSM.h),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: tiles[i]),
                  SizedBox(width: AppDesignSystem.spacingSM.w),
                  if (i + 1 < tiles.length)
                    Expanded(child: tiles[i + 1])
                  else
                    const Expanded(child: SizedBox()),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// A single chamfered action tile — icon chip + label + trailing chevron.
class _DeckTile extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  final bool fullWidth;

  const _DeckTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final tint = danger
        ? AppDesignSystem.errorColor
        : AppDesignSystem.primaryStrong;
    final shape = ChamferBorder(
      cut: 12,
      side: BorderSide(
        color: danger
            ? AppDesignSystem.errorColor.withValues(alpha: 0.35)
            : AppDesignSystem.borderColor,
      ),
    );
    return Material(
      color: AppDesignSystem.surfaceRaised,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
          child: Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: tint.withValues(alpha: 0.12),
                  shape: const ChamferBorder(cut: 9),
                ),
                child: icon,
              ),
              SizedBox(width: AppDesignSystem.spacingSM.w),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppDesignSystem.labelLarge.copyWith(
                    color: danger
                        ? AppDesignSystem.errorColor
                        : AppDesignSystem.textPrimary,
                    fontWeight: AppDesignSystem.bold,
                  ),
                ),
              ),
              if (fullWidth)
                Icon(Icons.chevron_right,
                    size: AppDesignSystem.iconSizeSM.sp,
                    color: danger
                        ? AppDesignSystem.errorColor.withValues(alpha: 0.7)
                        : AppDesignSystem.textFaint),
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
