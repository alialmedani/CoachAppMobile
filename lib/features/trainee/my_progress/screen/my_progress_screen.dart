import 'package:coachappmobile/core/boilerplate/get_model/cubits/get_model_cubit.dart';
import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/constant/app_icons/app_icons.dart';
import 'package:coachappmobile/core/ui/widgets/app_icon.dart';
import 'package:coachappmobile/core/ui/widgets/apex/duotone_hero.dart';
import 'package:coachappmobile/core/ui/widgets/apex/gauge_meter.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/tracking/data/model/progress_entry_model.dart';
import 'package:coachappmobile/features/coach/tracking/data/model/trainee_dashboard_model.dart';
import 'package:coachappmobile/features/coach/tracking/widgets/progress_trend_chart.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../my_dashboard/cubit/my_dashboard_cubit.dart';
import '../cubit/my_progress_cubit.dart';
import 'my_progress_detail_screen.dart';
import 'my_progress_editor_screen.dart';

/// The trainee's "Progress" tab, rebuilt on the Apex language: a duotone hero
/// with a workout-**consistency Gauge** and the current-weight headline, an
/// instrument **stat row** (sessions · adherence · body-fat), the weight **trend
/// chart**, and the measurement history. Tapping an entry opens a read-only
/// detail where the trainee can edit / delete their OWN entries; coach-authored
/// entries are read-only.
class MyProgressScreen extends StatefulWidget {
  final bool embedded;

  const MyProgressScreen({super.key, this.embedded = false});

  @override
  State<MyProgressScreen> createState() => _MyProgressScreenState();
}

class _MyProgressScreenState extends State<MyProgressScreen> {
  GetModelCubit? _list;

  void _refresh() => _list?.getModel();

  static String _fmtDate(DateTime? d) {
    if (d == null) return '';
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  Future<void> _add(MyProgressCubit cubit) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const MyProgressEditorScreen(),
        ),
      ),
    );
    if (created == true) _refresh();
  }

  Future<void> _openDetail(MyProgressCubit cubit, ProgressEntryModel e) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: MyProgressDetailScreen(entry: e),
        ),
      ),
    );
    if (changed == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyProgressCubit>();
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceCanvas,
      appBar: widget.embedded ? null : AppTopBar(title: 'progress'.tr()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(cubit),
        backgroundColor: AppDesignSystem.primaryColor,
        foregroundColor: AppDesignSystem.onPrimary,
        icon: const Icon(Icons.add),
        label: Text('add_progress'.tr()),
      ),
      body: GetModel<List<ProgressEntryModel>>(
        onCubitCreated: (c) => _list = c,
        useCaseCallBack: () => cubit.fetchRecent(),
        modelBuilder: (entries) {
          // Weight series (oldest → newest) + derived headline / change.
          final weightPoints = <TrendPoint>[
            for (final e in entries.reversed)
              if (e.weightKg != null && e.date != null)
                TrendPoint(e.date!, e.weightKg!),
          ];
          final latestWeight =
              weightPoints.isNotEmpty ? weightPoints.last.value : null;
          final weightDelta = weightPoints.length >= 2
              ? weightPoints.last.value - weightPoints.first.value
              : null;
          // Latest body-fat reading (entries arrive newest-first).
          double? latestBodyFat;
          for (final e in entries) {
            if (e.bodyFatPercent != null) {
              latestBodyFat = e.bodyFatPercent;
              break;
            }
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacingMD.h,
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacing4XL.h,
            ),
            children: [
              _ProgressHeader(
                latestWeight: latestWeight,
                weightDelta: weightDelta,
                latestBodyFat: latestBodyFat,
              ),
              SizedBox(height: AppDesignSystem.spacingXL.h),
              ProgressTrendChart(
                title: 'weight'.tr(),
                unit: 'unit_kg'.tr(),
                points: weightPoints,
              ),
              SizedBox(height: AppDesignSystem.spacingXL.h),
              _SectionRow(icon: AppIcons.plate, title: 'measurements'.tr()),
              SizedBox(height: AppDesignSystem.spacingSM.h),
              if (entries.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: AppDesignSystem.spacingLG.h),
                  child: AppEmptyState(
                    icon: Icons.insights_outlined,
                    title: 'no_progress_entries'.tr(),
                    subtitle: 'no_my_progress_subtitle'.tr(),
                    iconColor: AppDesignSystem.primaryColor,
                  ),
                )
              else
                for (final e in entries)
                  _EntryCard(
                    entry: e,
                    dateLabel: _fmtDate(e.date),
                    onTap: () => _openDetail(cubit, e),
                  ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// Header — duotone hero (consistency gauge + weight) over an instrument row
// ============================================================================

/// Loads the trainee's dashboard summary once and feeds both the hero gauge
/// (workout completion) and the stat row (sessions · adherence), combining it
/// with the entry-derived weight/body-fat figures.
class _ProgressHeader extends StatelessWidget {
  final double? latestWeight;
  final double? weightDelta;
  final double? latestBodyFat;

  const _ProgressHeader({
    required this.latestWeight,
    required this.weightDelta,
    required this.latestBodyFat,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyDashboardCubit>();
    return GetModel<TraineeDashboardModel>(
      useCaseCallBack: () => cubit.fetchSummary(),
      loadingWidget: SizedBox(
        height: 200.h,
        child: const Center(child: CircularProgressIndicator()),
      ),
      modelBuilder: (d) {
        final c = d.workoutCompletion;
        final a = d.nutritionAdherence;
        final planned = c?.plannedSessions ?? 0;
        final done = c?.completedSessions ?? 0;
        final hasCompletion = c != null && c.hasActivePlan && planned > 0;
        final frac = hasCompletion ? (done / planned).clamp(0.0, 1.0) : null;

        final adherencePct = (a != null && a.hasActivePlan)
            ? (a.overallPercent ?? a.caloriesPercent)
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Hero(
              completion: frac,
              latestWeight: latestWeight,
              weightDelta: weightDelta,
            ),
            SizedBox(height: AppDesignSystem.spacingMD.h),
            Row(
              children: [
                _InstrumentTile(
                  label: 'sessions'.tr(),
                  value: hasCompletion ? '$done/$planned' : '—',
                  accent: AppDesignSystem.primaryStrong,
                ),
                SizedBox(width: AppDesignSystem.spacingSM.w),
                _InstrumentTile(
                  label: 'adherence'.tr(),
                  value: adherencePct != null
                      ? 'percent_value'.tr(args: ['${adherencePct.round()}'])
                      : '—',
                  accent: AppDesignSystem.infoColor,
                ),
                SizedBox(width: AppDesignSystem.spacingSM.w),
                _InstrumentTile(
                  label: 'body_fat'.tr(),
                  value: latestBodyFat != null
                      ? '${_MyProgressScreenState._n(latestBodyFat!)}%'
                      : '—',
                  accent: AppDesignSystem.accentColor,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  final double? completion;
  final double? latestWeight;
  final double? weightDelta;

  const _Hero({
    required this.completion,
    required this.latestWeight,
    required this.weightDelta,
  });

  String _statusKey(double s) => s >= 0.8
      ? 'status_great'
      : s >= 0.4
      ? 'status_on_track'
      : 'status_get_started';

  @override
  Widget build(BuildContext context) {
    final score = completion;
    return DuotoneHero(
      ghostText: latestWeight != null
          ? _MyProgressScreenState._n(latestWeight!)
          : 'progress'.tr(),
      // Only the gauge is circular — drop the decorative plate when it shows.
      showPlate: score == null,
      child: Row(
        children: [
          if (score != null)
            GaugeMeter(
              value: score,
              size: 108.w,
              caption: _statusKey(score).tr(),
            )
          else
            SizedBox(
              width: 108.w,
              height: 108.w,
              child: Center(
                child: AppIcon(
                  AppIcons.progress,
                  size: AppDesignSystem.iconSizeLG,
                  color: AppDesignSystem.primaryStrong,
                ),
              ),
            ),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'progress'.tr().toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: AppDesignSystem.fontSizeSM.sp,
                    fontWeight: AppDesignSystem.bold,
                    letterSpacing: 1.5,
                    color: AppDesignSystem.primaryStrong,
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacing2XS.h),
                if (latestWeight != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _MyProgressScreenState._n(latestWeight!),
                        style: TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: AppDesignSystem.fontSize4XL.sp,
                          fontWeight: AppDesignSystem.extraBold,
                          height: 1,
                          letterSpacing: -1,
                          color: AppDesignSystem.textPrimary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      SizedBox(width: AppDesignSystem.spacingXS.w),
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Text(
                          'unit_kg'.tr(),
                          style: AppDesignSystem.bodySmall
                              .copyWith(color: AppDesignSystem.textFaint),
                        ),
                      ),
                    ],
                  ),
                  if (weightDelta != null) ...[
                    SizedBox(height: 2.h),
                    _DeltaRow(delta: weightDelta!),
                  ],
                ] else
                  Text(
                    'no_my_progress_subtitle'.tr(),
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

class _DeltaRow extends StatelessWidget {
  final double delta;
  const _DeltaRow({required this.delta});

  @override
  Widget build(BuildContext context) {
    final icon = delta > 0
        ? Icons.trending_up
        : (delta < 0 ? Icons.trending_down : Icons.trending_flat);
    final sign = delta > 0 ? '+' : '';
    return Row(
      children: [
        Icon(icon, size: AppDesignSystem.iconSizeXS.sp,
            color: AppDesignSystem.textMuted),
        SizedBox(width: AppDesignSystem.spacingXS.w),
        Text(
          '$sign${_MyProgressScreenState._n(delta)} ${'unit_kg'.tr()} · ${'since_start'.tr()}',
          style: AppDesignSystem.bodySmall
              .copyWith(color: AppDesignSystem.textMuted),
        ),
      ],
    );
  }
}

/// A compact instrument readout — a big tabular figure over a small caption on
/// a sunken tile. Three of these form the stat row under the hero.
class _InstrumentTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _InstrumentTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppDesignSystem.spacingMD.h,
          horizontal: AppDesignSystem.spacingSM.w,
        ),
        decoration: BoxDecoration(
          color: AppDesignSystem.surfaceRaised,
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
                letterSpacing: -0.5,
                color: accent,
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

// ============================================================================
// Measurement history
// ============================================================================

class _SectionRow extends StatelessWidget {
  final String icon;
  final String title;

  const _SectionRow({required this.icon, required this.title});

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

class _EntryCard extends StatelessWidget {
  final ProgressEntryModel entry;
  final String dateLabel;
  final VoidCallback onTap;

  const _EntryCard({
    required this.entry,
    required this.dateLabel,
    required this.onTap,
  });

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: AppDesignSystem.spacingSM.h),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppDesignSystem.primaryStrong.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
            ),
            child: AppIcon(AppIcons.gauge,
                size: AppDesignSystem.iconSizeSM,
                color: AppDesignSystem.primaryStrong),
          ),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel,
                  style: AppDesignSystem.bodyLarge.copyWith(
                    color: AppDesignSystem.textPrimary,
                    fontWeight: AppDesignSystem.semiBold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacing2XS.h),
                Text(
                  (entry.isCoachAuthored ? 'added_by_coach' : 'added_by_you')
                      .tr(),
                  style: AppDesignSystem.labelSmall.copyWith(
                    color: entry.isCoachAuthored
                        ? AppDesignSystem.infoColor
                        : AppDesignSystem.textFaint,
                  ),
                ),
              ],
            ),
          ),
          if (entry.weightKg != null)
            Padding(
              padding: EdgeInsetsDirectional.only(
                end: AppDesignSystem.spacingSM.w,
              ),
              child: AppBadge(
                text: '${_n(entry.weightKg!)} ${'unit_kg'.tr()}',
                variant: AppBadgeVariant.primary,
                size: AppBadgeSize.small,
              ),
            ),
          if (entry.bodyFatPercent != null)
            AppBadge(
              text: '${_n(entry.bodyFatPercent!)}%',
              variant: AppBadgeVariant.info,
              size: AppBadgeSize.small,
            ),
          Icon(
            Icons.chevron_right,
            color: AppDesignSystem.textFaint,
            size: AppDesignSystem.iconSizeSM.sp,
          ),
        ],
      ),
    );
  }
}
