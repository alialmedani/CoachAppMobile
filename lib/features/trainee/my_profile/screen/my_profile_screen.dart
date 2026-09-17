import 'package:coachappmobile/core/boilerplate/get_model/cubits/get_model_cubit.dart';
import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/constant/app_icons/app_icons.dart';
import 'package:coachappmobile/core/di/injection.dart';
import 'package:coachappmobile/core/ui/shapes/chamfer.dart';
import 'package:coachappmobile/core/ui/widgets/apex/athlete_credential.dart';
import 'package:coachappmobile/core/ui/widgets/app_icon.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/auth/cubit/session_cubit.dart';
import 'package:coachappmobile/features/auth/screen/change_password_screen.dart';
import 'package:coachappmobile/features/coach/tracking/data/model/progress_entry_model.dart';
import 'package:coachappmobile/features/coach/trainees/data/model/trainee_model.dart';
import 'package:coachappmobile/features/trainee/my_notes/cubit/my_notes_cubit.dart';
import 'package:coachappmobile/features/trainee/my_notes/screen/my_notes_screen.dart';
import 'package:coachappmobile/features/trainee/my_progress/cubit/my_progress_cubit.dart';
import 'package:coachappmobile/features/trainee/my_progress/data/params/create_my_progress_params.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/my_profile_cubit.dart';
import 'my_profile_edit_screen.dart';

String _n(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

String _num(double? v, String unit) => v == null ? '—' : '${_n(v)} $unit';

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

/// The trainee's "Profile" tab, rebuilt as the Apex flagship: a premium athlete
/// **credential** card, a signature **body-composition journey** rail (start →
/// now → goal weight), a spec-sheet detail grid, and a chamfered control deck —
/// all entering on a choreographed staggered reveal. Keeps the restricted
/// self-edit + coach-notes / change-password / logout entries and the quick
/// "record today's weight" flow.
class MyProfileScreen extends StatefulWidget {
  /// Optional signal, fired by the shell when the user switches to the Profile
  /// tab from Progress. The body listens and refetches the derived current
  /// weight, so a progress entry just added on the Progress tab (a separate
  /// cubit instance) is reflected here without a manual pull-to-refresh.
  final Listenable? refreshSignal;

  const MyProfileScreen({super.key, this.refreshSignal});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen>
    with SingleTickerProviderStateMixin {
  GetModelCubit? _getModel;

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

  Future<void> _edit(MyProfileCubit cubit, TraineeModel p) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: MyProfileEditScreen(profile: p),
        ),
      ),
    );
    if (changed == true) _getModel?.getModel();
  }

  void _openNotes() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => getIt<MyNotesCubit>(),
        child: const MyNotesScreen(),
      ),
    ),
  );

  void _openChangePassword() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
  );

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyProfileCubit>();
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceCanvas,
      body: GetModel<TraineeModel>(
        onCubitCreated: (c) => _getModel = c,
        useCaseCallBack: () => cubit.fetchProfile(),
        modelBuilder: (p) {
          _startReveal();
          final age = _age(p.birthDate);
          return SafeArea(
            bottom: false,
            child: ListView(
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
                    name: p.fullName,
                    initial: p.initial,
                    athleteId:
                        'APX · ${(p.userName ?? p.initial).toUpperCase()}',
                    memberSince: p.creationTime != null
                        ? '${'member_since'.tr()} ${p.creationTime!.year}'
                        : 'member_since'.tr(),
                    ageLabel: age != null
                        ? 'years_old'.tr(args: ['$age'])
                        : null,
                    goalLabel: p.goal.labelKey.tr(),
                    active: p.isActive,
                    statusLabel: (p.isActive ? 'active' : 'inactive').tr(),
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacingLG.h),
                _staggered(
                  1,
                  _JourneySection(
                    startWeight: p.startWeightKg,
                    targetWeight: p.targetWeightKg,
                    refreshSignal: widget.refreshSignal,
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacingLG.h),
                _staggered(2, _SectionLabel(
                  icon: AppIcons.profile,
                  title: 'details'.tr(),
                )),
                SizedBox(height: AppDesignSystem.spacingSM.h),
                _staggered(3, _SpecGrid(profile: p, age: age)),
                SizedBox(height: AppDesignSystem.spacingLG.h),
                _staggered(4, _SectionLabel(
                  icon: AppIcons.bolt,
                  title: 'account'.tr(),
                )),
                SizedBox(height: AppDesignSystem.spacingSM.h),
                _staggered(
                  5,
                  _ControlDeck(
                    onEdit: () => _edit(cubit, p),
                    onNotes: _openNotes,
                    onChangePassword: _openChangePassword,
                    onLogout: () => context.read<SessionCubit>().logout(),
                  ),
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
// Body-composition journey — start → now → goal
// ============================================================================

class _JourneySection extends StatefulWidget {
  final double? startWeight;
  final double? targetWeight;
  final Listenable? refreshSignal;

  const _JourneySection({
    this.startWeight,
    this.targetWeight,
    this.refreshSignal,
  });

  @override
  State<_JourneySection> createState() => _JourneySectionState();
}

class _JourneySectionState extends State<_JourneySection> {
  GetModelCubit? _model;

  @override
  void initState() {
    super.initState();
    widget.refreshSignal?.addListener(_onRefreshSignal);
  }

  @override
  void didUpdateWidget(covariant _JourneySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshSignal != widget.refreshSignal) {
      oldWidget.refreshSignal?.removeListener(_onRefreshSignal);
      widget.refreshSignal?.addListener(_onRefreshSignal);
    }
  }

  @override
  void dispose() {
    widget.refreshSignal?.removeListener(_onRefreshSignal);
    super.dispose();
  }

  /// Re-fetch the recent progress entries so the derived current weight reflects
  /// an entry just added on the Progress tab.
  void _onRefreshSignal() => _model?.getModel();

  static double? _latestWeight(List<ProgressEntryModel> entries) {
    for (final e in entries) {
      if (e.weightKg != null) return e.weightKg;
    }
    return null;
  }

  static bool _isToday(DateTime? d) {
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  void _snack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  /// Logs today's weight: updates the trainee's OWN entry for today if one
  /// exists (preserving its other measurements), otherwise creates a new entry.
  Future<void> _record(List<ProgressEntryModel> entries) async {
    final cubit = context.read<MyProgressCubit>();
    final value = await showDialog<double>(
      context: context,
      builder: (_) => _RecordWeightDialog(initial: _latestWeight(entries)),
    );
    if (value == null || !mounted) return;
    final now = DateTime.now();
    final ownToday =
        entries.where((e) => !e.isCoachAuthored && _isToday(e.date)).toList();
    final result = ownToday.isNotEmpty
        ? await cubit.updateEntry(
            UpdateMyProgressParams(
              id: ownToday.first.id ?? '',
              date: (ownToday.first.date ?? now).toIso8601String(),
              weightKg: value,
              bodyFatPercent: ownToday.first.bodyFatPercent,
              chestCm: ownToday.first.chestCm,
              waistCm: ownToday.first.waistCm,
              hipsCm: ownToday.first.hipsCm,
              armCm: ownToday.first.armCm,
              thighCm: ownToday.first.thighCm,
              notes: ownToday.first.notes,
            ),
          )
        : await cubit.createEntry(
            CreateMyProgressParams(
              date: DateTime(now.year, now.month, now.day).toIso8601String(),
              weightKg: value,
            ),
          );
    if (!mounted) return;
    if (result.hasDataOnly) {
      _model?.getModel();
      _snack('weight_saved'.tr(), AppDesignSystem.successColor);
    } else {
      _snack(
        result.error ?? 'something_went_wrong'.tr(),
        AppDesignSystem.errorColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyProgressCubit>();
    return GetModel<List<ProgressEntryModel>>(
      onCubitCreated: (c) => _model = c,
      useCaseCallBack: () => cubit.fetchRecent(),
      loadingWidget: SizedBox(
        height: 150.h,
        child: const Center(child: CircularProgressIndicator()),
      ),
      modelBuilder: (entries) {
        final current = _latestWeight(entries);
        return _JourneyPanel(
          start: widget.startWeight,
          current: current,
          target: widget.targetWeight,
          onRecord: () => _record(entries),
        );
      },
    );
  }
}

class _JourneyPanel extends StatelessWidget {
  final double? start;
  final double? current;
  final double? target;
  final VoidCallback onRecord;

  const _JourneyPanel({
    required this.start,
    required this.current,
    required this.target,
    required this.onRecord,
  });

  @override
  Widget build(BuildContext context) {
    final hasRail = start != null &&
        target != null &&
        current != null &&
        start != target;

    double? progress;
    double? toGo;
    if (hasRail) {
      progress = ((current! - start!) / (target! - start!)).clamp(0.0, 1.0);
      toGo = (target! - current!).abs();
    }

    return Container(
      padding: EdgeInsets.all(AppDesignSystem.spacingLG.w),
      decoration: BoxDecoration(
        color: AppDesignSystem.surfaceRaised,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusLG.r),
        border: Border.all(color: AppDesignSystem.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppIcon(AppIcons.gauge,
                  size: AppDesignSystem.iconSizeSM,
                  color: AppDesignSystem.primaryStrong),
              SizedBox(width: AppDesignSystem.spacingXS.w),
              Expanded(
                child: Text(
                  'body_composition'.tr(),
                  style: AppDesignSystem.h6
                      .copyWith(color: AppDesignSystem.textPrimary),
                ),
              ),
              if (progress != null)
                Text(
                  'percent_value'.tr(args: ['${(progress * 100).round()}']),
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: AppDesignSystem.fontSizeLG.sp,
                    fontWeight: AppDesignSystem.extraBold,
                    color: AppDesignSystem.primaryStrong,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
          SizedBox(height: AppDesignSystem.spacingLG.h),
          if (hasRail)
            _Rail(
              start: start!,
              current: current!,
              target: target!,
              progress: progress!,
            )
          else
            _CurrentOnly(current: current),
          if (hasRail) ...[
            SizedBox(height: AppDesignSystem.spacingMD.h),
            Center(
              child: Text(
                toGo! < 0.05
                    ? 'goal_reached'.tr()
                    : 'weight_to_go'.tr(args: [_n(toGo)]),
                style: AppDesignSystem.bodySmall
                    .copyWith(color: AppDesignSystem.textMuted),
              ),
            ),
          ],
          SizedBox(height: AppDesignSystem.spacingLG.h),
          _ChamferAction(
            icon: Icons.add,
            label: 'record_current_weight'.tr(),
            onTap: onRecord,
          ),
        ],
      ),
    );
  }
}

/// The rail: a sunken track with a Volt fill from START to the current marker,
/// a floating current-weight pill above it, and start/goal end anchors. RTL-safe
/// via [PositionedDirectional] (fills from the leading edge).
class _Rail extends StatelessWidget {
  final double start;
  final double current;
  final double target;
  final double progress;

  const _Rail({
    required this.start,
    required this.current,
    required this.target,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        const pillW = 78.0;
        final trackTop = 46.h;
        final markerX = (w * progress - pillW / 2).clamp(0.0, w - pillW);
        final markerCenter = (w * progress).clamp(6.0, w - 6.0);

        return SizedBox(
          height: 96.h,
          child: Stack(
            children: [
              // Track (sunken).
              PositionedDirectional(
                start: 0,
                end: 0,
                top: trackTop,
                child: Container(
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: AppDesignSystem.surfaceSunken,
                    borderRadius:
                        BorderRadius.circular(AppDesignSystem.radiusFull.r),
                    border: Border.all(color: AppDesignSystem.borderColor),
                  ),
                ),
              ),
              // Filled portion START → current.
              PositionedDirectional(
                start: 0,
                top: trackTop,
                width: markerCenter,
                child: Container(
                  height: 10.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppDesignSystem.primaryColor.withValues(alpha: 0.5),
                        AppDesignSystem.primaryColor,
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(AppDesignSystem.radiusFull.r),
                  ),
                ),
              ),
              // Marker dot on the track.
              PositionedDirectional(
                start: markerCenter - 7,
                top: trackTop - 2.h,
                child: Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: AppDesignSystem.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppDesignSystem.surfaceRaised, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppDesignSystem.primaryColor.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
              // Floating current-weight pill above the marker.
              PositionedDirectional(
                start: markerX,
                top: 0,
                child: _CurrentPill(value: current, width: pillW),
              ),
              // Start / Goal end anchors.
              PositionedDirectional(
                start: 0,
                top: trackTop + 18.h,
                child: _Anchor(
                  labelKey: 'starting',
                  value: '${_n(start)} ${'unit_kg'.tr()}',
                  align: CrossAxisAlignment.start,
                ),
              ),
              PositionedDirectional(
                end: 0,
                top: trackTop + 18.h,
                child: _Anchor(
                  labelKey: 'goal',
                  value: '${_n(target)} ${'unit_kg'.tr()}',
                  align: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CurrentPill extends StatelessWidget {
  final double value;
  final double width;

  const _CurrentPill({required this.value, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width.w,
      child: Column(
        children: [
          Text(
            'now'.tr().toUpperCase(),
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: AppDesignSystem.fontSizeXS.sp,
              fontWeight: AppDesignSystem.bold,
              letterSpacing: 1,
              color: AppDesignSystem.primaryStrong,
            ),
          ),
          SizedBox(height: 1.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _n(value),
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: AppDesignSystem.fontSize2XL.sp,
                    fontWeight: AppDesignSystem.extraBold,
                    height: 1,
                    letterSpacing: -0.5,
                    color: AppDesignSystem.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  'unit_kg'.tr(),
                  style: AppDesignSystem.labelSmall
                      .copyWith(color: AppDesignSystem.textFaint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Anchor extends StatelessWidget {
  final String labelKey;
  final String value;
  final CrossAxisAlignment align;

  const _Anchor({
    required this.labelKey,
    required this.value,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          labelKey.tr().toUpperCase(),
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: AppDesignSystem.fontSizeXS.sp,
            fontWeight: AppDesignSystem.bold,
            letterSpacing: 1,
            color: AppDesignSystem.textFaint,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppDesignSystem.labelMedium.copyWith(
            color: AppDesignSystem.textMuted,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// Fallback when there aren't enough anchors to draw the rail: just the current
/// weight, big.
class _CurrentOnly extends StatelessWidget {
  final double? current;
  const _CurrentOnly({required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          current != null ? _n(current!) : '—',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: AppDesignSystem.fontSize4XL.sp,
            fontWeight: AppDesignSystem.extraBold,
            height: 1,
            letterSpacing: -1,
            color: current != null
                ? AppDesignSystem.textPrimary
                : AppDesignSystem.textFaint,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        SizedBox(width: AppDesignSystem.spacingXS.w),
        Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Text(
            current != null ? 'unit_kg'.tr() : 'no_weight_logged'.tr(),
            style: AppDesignSystem.bodySmall
                .copyWith(color: AppDesignSystem.textFaint),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Spec grid — the detail "spec sheet"
// ============================================================================

class _SpecGrid extends StatelessWidget {
  final TraineeModel profile;
  final int? age;

  const _SpecGrid({required this.profile, required this.age});

  @override
  Widget build(BuildContext context) {
    final p = profile;
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
        icon: Icon(Icons.straighten_outlined,
            size: AppDesignSystem.iconSizeXS.sp,
            color: AppDesignSystem.primaryStrong),
        label: 'height_cm'.tr(),
        value: _num(p.heightCm, 'unit_cm'.tr()),
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
// Control deck — actions as premium chamfered rows
// ============================================================================

class _ControlDeck extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onNotes;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;

  const _ControlDeck({
    required this.onEdit,
    required this.onNotes,
    required this.onChangePassword,
    required this.onLogout,
  });

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
          _ControlRow(
            icon: Icons.edit_outlined,
            label: 'edit_profile'.tr(),
            onTap: onEdit,
            first: true,
          ),
          _divider(),
          _ControlRow(
            icon: Icons.sticky_note_2_outlined,
            label: 'coach_notes'.tr(),
            onTap: onNotes,
          ),
          _divider(),
          _ControlRow(
            icon: Icons.lock_outline,
            label: 'change_password'.tr(),
            onTap: onChangePassword,
          ),
          _divider(),
          _ControlRow(
            icon: Icons.logout,
            label: 'logout'.tr(),
            onTap: onLogout,
            danger: true,
            last: true,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
    height: 1,
    thickness: 1,
    indent: AppDesignSystem.spacingMD.w,
    endIndent: AppDesignSystem.spacingMD.w,
    color: AppDesignSystem.borderColor,
  );
}

class _ControlRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  final bool first;
  final bool last;

  const _ControlRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
    this.first = false,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final tint =
        danger ? AppDesignSystem.errorColor : AppDesignSystem.primaryStrong;
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
          padding: EdgeInsets.symmetric(
            horizontal: AppDesignSystem.spacingMD.w,
            vertical: AppDesignSystem.spacingMD.h,
          ),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: tint.withValues(alpha: 0.12),
                  shape: const ChamferBorder(cut: 9),
                ),
                child: Icon(icon,
                    size: AppDesignSystem.iconSizeSM.sp, color: tint),
              ),
              SizedBox(width: AppDesignSystem.spacingMD.w),
              Expanded(
                child: Text(
                  label,
                  style: AppDesignSystem.bodyLarge.copyWith(
                    color: danger
                        ? AppDesignSystem.errorColor
                        : AppDesignSystem.textPrimary,
                    fontWeight: AppDesignSystem.semiBold,
                  ),
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

/// A full-width chamfered action — the Apex answer to a "button": an outlined
/// equipment-tag with a Volt border and a chamfer-clipped ripple.
class _ChamferAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ChamferAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const shape = ChamferBorder(cut: 12);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: Container(
          height: 48.h,
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: AppDesignSystem.primaryColor.withValues(alpha: 0.08),
            shape: ChamferBorder(
              cut: 12,
              side: BorderSide(
                color: AppDesignSystem.primaryColor.withValues(alpha: 0.55),
                width: 1.4,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: AppDesignSystem.iconSizeSM.sp,
                  color: AppDesignSystem.primaryStrong),
              SizedBox(width: AppDesignSystem.spacingXS.w),
              Text(
                label,
                style: AppDesignSystem.labelLarge.copyWith(
                  color: AppDesignSystem.primaryStrong,
                  fontWeight: AppDesignSystem.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Minimal numeric weight input (kg) for the quick "record today's weight" flow.
class _RecordWeightDialog extends StatefulWidget {
  final double? initial;

  const _RecordWeightDialog({this.initial});

  @override
  State<_RecordWeightDialog> createState() => _RecordWeightDialogState();
}

class _RecordWeightDialogState extends State<_RecordWeightDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final v = widget.initial;
    _controller = TextEditingController(
      text: v == null
          ? ''
          : (v == v.roundToDouble() ? v.toInt().toString() : '$v'),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context, double.parse(_controller.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppDesignSystem.surfaceRaised,
      title: Text('record_current_weight'.tr()),
      content: Form(
        key: _formKey,
        child: AppTextField(
          label: 'weight_kg'.tr(),
          hint: '0',
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          validator: (v) {
            final n = double.tryParse((v ?? '').trim());
            if (n == null || n <= 0 || n > 500) return 'weight_range_error'.tr();
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        TextButton(onPressed: _save, child: Text('save'.tr())),
      ],
    );
  }
}
