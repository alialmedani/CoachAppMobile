import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/apex/gauge_meter.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/screen/widgets/macro_summary_card.dart';
import 'package:coachappmobile/features/trainee/today/data/model/nutrition_adherence_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../data/model/nutrition_adherence_range_model.dart';
import '../data/model/workout_completion_model.dart';

/// The shared dashboard cards — **nutrition adherence** (consumed vs target),
/// optionally the **range/weekly nutrition adherence** (F5/PD5), and **workout
/// completion** (completed vs planned). Percentages are uncapped: the bars cap
/// at 100% but labels show the true value. Reused by coach tracking (Phase 11)
/// and the trainee dashboard (Phase 16). The nutrition/workout inputs are
/// nullable (null ⇒ no data / no active plan → an info card is shown).
///
/// [range] and [showNotLoggedState] are opt-in (default null/false) so existing
/// call sites (e.g. the trainee progress tab) render exactly as before:
/// * [range] — when provided (and the plan is active) renders the weekly/range
///   average adherence card beneath the single-day card.
/// * [showNotLoggedState] — when true and the selected day has an active plan
///   but no log yet, shows a neutral "not logged yet today" card instead of a
///   0%/empty macro card.
class DashboardCards extends StatelessWidget {
  final NutritionAdherenceModel? adherence;
  final NutritionAdherenceRangeModel? range;
  final WorkoutCompletionModel? completion;
  final bool showNotLoggedState;

  const DashboardCards({
    super.key,
    this.adherence,
    this.range,
    this.completion,
    this.showNotLoggedState = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = adherence;
    final r = range;
    final c = completion;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildNutritionCard(a),
        if (r != null && r.hasActivePlan) ...[
          SizedBox(height: AppDesignSystem.spacingMD.h),
          _RangeAdherenceCard(range: r),
        ],
        SizedBox(height: AppDesignSystem.spacingMD.h),
        if (c != null && c.hasActivePlan)
          _WorkoutCompletionCard(completion: c)
        else
          _InfoCard(
            icon: Icons.fitness_center_outlined,
            title: 'no_active_workout_plan'.tr(),
            subtitle: 'no_workout_completion_subtitle'.tr(),
          ),
      ],
    );
  }

  Widget _buildNutritionCard(NutritionAdherenceModel? a) {
    if (a == null || !a.hasActivePlan) {
      return _InfoCard(
        icon: Icons.restaurant_outlined,
        title: 'no_active_nutrition_plan'.tr(),
        subtitle: 'no_nutrition_adherence_subtitle'.tr(),
      );
    }
    if (showNotLoggedState && !a.hasLog) {
      return _InfoCard(
        icon: Icons.schedule_outlined,
        title: 'not_logged_yet_today'.tr(),
        subtitle: 'not_logged_yet_today_subtitle'.tr(),
      );
    }
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

/// F5/PD5: nutrition adherence averaged over the selected window — average daily
/// calorie adherence plus a coverage line (days logged / days in range). A
/// neutral "not logged yet" state replaces a misleading 0% when nothing is
/// logged in the window.
class _RangeAdherenceCard extends StatelessWidget {
  final NutritionAdherenceRangeModel range;

  const _RangeAdherenceCard({required this.range});

  @override
  Widget build(BuildContext context) {
    final pct = range.averageCaloriesPercent;
    final logged = range.daysLogged > 0 && pct != null;
    final title = range.daysInRange <= 7
        ? 'weekly_average'.tr()
        : 'range_average_adherence'.tr();
    return _GaugeStatCard(
      icon: Icons.insights_outlined,
      title: title,
      caption: 'adherence'.tr(),
      percent: logged ? pct : null,
      primaryLine: logged
          ? 'average_daily_calories_adherence'.tr()
          : 'not_logged_yet_range'.tr(),
      secondaryLine: 'days_logged_of_range'.tr(
        args: ['${range.daysLogged}', '${range.daysInRange}'],
      ),
    );
  }
}

class _WorkoutCompletionCard extends StatelessWidget {
  final WorkoutCompletionModel completion;

  const _WorkoutCompletionCard({required this.completion});

  @override
  Widget build(BuildContext context) {
    final planned = completion.plannedSessions ?? 0;
    final done = completion.completedSessions;
    final pct = completion.completionPercent ??
        (planned > 0 ? (done / planned) * 100 : null);
    return _GaugeStatCard(
      icon: Icons.fitness_center_outlined,
      title: 'workout_completion'.tr(),
      caption: 'sessions'.tr(),
      percent: pct,
      primaryLine: 'sessions_done_of_planned'.tr(args: ['$done', '$planned']),
      secondaryLine: 'over_weeks'.tr(args: ['${completion.weeks}']),
    );
  }
}

/// A tracking KPI card built around the Apex [GaugeMeter]: the gauge on the
/// leading edge (arc caps at 100%), the metric title, and two supporting lines.
class _GaugeStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String caption;
  final double? percent;
  final String primaryLine;
  final String secondaryLine;

  const _GaugeStatCard({
    required this.icon,
    required this.title,
    required this.caption,
    required this.percent,
    required this.primaryLine,
    required this.secondaryLine,
  });

  @override
  Widget build(BuildContext context) {
    final frac = ((percent ?? 0) / 100).clamp(0.0, 1.0);
    return AppCard(
      child: Row(
        children: [
          GaugeMeter(value: frac, size: 84.w, caption: caption),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon,
                        size: AppDesignSystem.iconSizeSM.sp,
                        color: AppDesignSystem.primaryStrong),
                    SizedBox(width: AppDesignSystem.spacingXS.w),
                    Expanded(
                      child: Text(
                        title,
                        style: AppDesignSystem.h6
                            .copyWith(color: AppDesignSystem.textPrimary),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDesignSystem.spacingXS.h),
                Text(
                  primaryLine,
                  style: AppDesignSystem.bodySmall
                      .copyWith(color: AppDesignSystem.textMuted),
                ),
                SizedBox(height: AppDesignSystem.spacing2XS.h),
                Text(
                  secondaryLine,
                  style: AppDesignSystem.labelMedium.copyWith(
                    color: AppDesignSystem.textFaint,
                    fontFeatures: const [FontFeature.tabularFigures()],
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Icon(
            icon,
            color: AppDesignSystem.neutral400,
            size: AppDesignSystem.iconSizeSM.sp,
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
