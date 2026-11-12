import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/constant/app_icons/app_icons.dart';
import 'package:coachappmobile/core/ui/widgets/app_icon.dart';
import 'package:coachappmobile/core/ui/widgets/apex/apex_segmented.dart';
import 'package:coachappmobile/core/ui/widgets/apex/duotone_hero.dart';
import 'package:coachappmobile/core/ui/widgets/apex/gauge_meter.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/coach_dashboard_cubit.dart';
import '../data/model/trainee_dashboard_model.dart';
import '../widgets/dashboard_cards.dart';

/// Coach dashboard for one trainee, on the Apex language: a duotone hero with the
/// readiness **Gauge** (a blended compliance score from the honest per-trainee
/// data), an Apex segmented range picker, then the detailed adherence /
/// completion instrument cards. Read-only; changing the range re-fetches.
class CoachDashboardScreen extends StatefulWidget {
  final String traineeId;
  final String? traineeName;

  const CoachDashboardScreen({
    super.key,
    required this.traineeId,
    this.traineeName,
  });

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  static const _ranges = <CoachDashboardRange>[
    CoachDashboardRange.today,
    CoachDashboardRange.thisWeek,
    CoachDashboardRange.last28Days,
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CoachDashboardCubit>()
      ..setTrainee(widget.traineeId);
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceCanvas,
      appBar: AppTopBar(
        title: 'coach_dashboard'.tr(),
        subtitle: widget.traineeName,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacingSM.h,
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacingXS.h,
            ),
            child: ApexSegmented(
              labels: [
                'range_today'.tr(),
                'range_this_week'.tr(),
                'range_last_28_days'.tr(),
              ],
              index: _ranges.indexOf(cubit.range),
              onChanged: (i) {
                if (_ranges[i] == cubit.range) return;
                setState(() => cubit.setRange(_ranges[i]));
              },
            ),
          ),
          Expanded(
            child: GetModel<TraineeDashboardModel>(
              // Re-fetch when the window changes: a key derived from the
              // selected range rebuilds GetModel and re-runs the use case.
              key: ValueKey(cubit.range),
              useCaseCallBack: () => cubit.fetchSummary(),
              modelBuilder: (d) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  AppDesignSystem.spacingMD.w,
                  AppDesignSystem.spacingSM.h,
                  AppDesignSystem.spacingMD.w,
                  AppDesignSystem.spacing3XL.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DashboardHero(
                      model: d,
                      range: cubit.range,
                      name: widget.traineeName,
                    ),
                    SizedBox(height: AppDesignSystem.spacingLG.h),
                    DashboardCards(
                      adherence: d.nutritionAdherence,
                      // The single-day card is the anchor day; hide the range
                      // card when the window is a single day (redundant).
                      range: cubit.range == CoachDashboardRange.today
                          ? null
                          : d.nutritionAdherenceRange,
                      completion: d.workoutCompletion,
                      showNotLoggedState: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The hero: a blended compliance gauge (nutrition + workout, whichever are
/// active) over the trainee context. Falls back to a calm banner when the
/// trainee has no active plans in the window.
class _DashboardHero extends StatelessWidget {
  final TraineeDashboardModel model;
  final CoachDashboardRange range;
  final String? name;

  const _DashboardHero({required this.model, required this.range, this.name});

  double? _score() {
    final parts = <double>[];
    final today = range == CoachDashboardRange.today;
    if (today) {
      final n = model.nutritionAdherence;
      if (n != null && n.hasActivePlan) {
        final pct = n.overallPercent ?? n.caloriesPercent ?? 0;
        parts.add((pct / 100).clamp(0.0, 1.0));
      }
    } else {
      final r = model.nutritionAdherenceRange;
      if (r != null && r.hasActivePlan && r.averageCaloriesPercent != null) {
        parts.add((r.averageCaloriesPercent! / 100).clamp(0.0, 1.0));
      }
    }
    final c = model.workoutCompletion;
    if (c != null && c.hasActivePlan && c.completionPercent != null) {
      parts.add((c.completionPercent! / 100).clamp(0.0, 1.0));
    }
    if (parts.isEmpty) return null;
    return parts.reduce((a, b) => a + b) / parts.length;
  }

  String _statusKey(double s) => s >= 0.8
      ? 'status_great'
      : s >= 0.4
      ? 'status_on_track'
      : 'status_get_started';

  String _subtitle() {
    final c = model.workoutCompletion;
    if (c != null && c.hasActivePlan) {
      return 'sessions_done_of_planned'
          .tr(args: ['${c.completedSessions}', '${c.plannedSessions ?? 0}']);
    }
    final r = model.nutritionAdherenceRange;
    if (range != CoachDashboardRange.today && r != null && r.hasActivePlan) {
      return 'days_logged_of_range'
          .tr(args: ['${r.daysLogged}', '${r.daysInRange}']);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final score = _score();
    if (score == null) {
      return DuotoneHero(
        ghostText: 'tracking'.tr(),
        child: Row(
          children: [
            AppIcon(AppIcons.gauge,
                size: AppDesignSystem.iconSizeLG,
                color: AppDesignSystem.primaryStrong),
            SizedBox(width: AppDesignSystem.spacingMD.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name ?? 'tracking'.tr(),
                      style: AppDesignSystem.h4
                          .copyWith(color: AppDesignSystem.textPrimary)),
                  SizedBox(height: AppDesignSystem.spacing2XS.h),
                  Text('no_active_plans_yet'.tr(),
                      style: AppDesignSystem.bodySmall
                          .copyWith(color: AppDesignSystem.textMuted)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final subtitle = _subtitle();
    return DuotoneHero(
      ghostText: 'tracking'.tr(),
      showPlate: false,
      child: Row(
        children: [
          GaugeMeter(value: score, size: 108.w, caption: _statusKey(score).tr()),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'tracking'.tr().toUpperCase(),
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
                  name ?? 'tracking'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
