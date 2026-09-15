import 'package:coachappmobile/core/boilerplate/get_model/cubits/get_model_cubit.dart';
import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/tracking/data/model/progress_entry_model.dart';
import 'package:coachappmobile/features/coach/tracking/data/model/trainee_dashboard_model.dart';
import 'package:coachappmobile/features/coach/tracking/widgets/dashboard_cards.dart';
import 'package:coachappmobile/features/coach/tracking/widgets/progress_trend_chart.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../my_dashboard/cubit/my_dashboard_cubit.dart';
import '../cubit/my_progress_cubit.dart';
import 'my_progress_detail_screen.dart';
import 'my_progress_editor_screen.dart';

/// The trainee's "Progress" tab: their own dashboard (adherence + completion),
/// a weight trend chart, and the progress-entry list. Tapping an entry opens a
/// read-only detail where the trainee can edit / delete their OWN entries;
/// coach-authored entries are read-only.
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
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: widget.embedded ? null : AppTopBar(title: 'progress'.tr()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(cubit),
        backgroundColor: AppDesignSystem.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('add_progress'.tr()),
      ),
      body: GetModel<List<ProgressEntryModel>>(
        onCubitCreated: (c) => _list = c,
        useCaseCallBack: () => cubit.fetchRecent(),
        modelBuilder: (entries) {
          final weightPoints = <TrendPoint>[
            for (final e in entries.reversed)
              if (e.weightKg != null && e.date != null)
                TrendPoint(e.date!, e.weightKg!),
          ];
          return ListView(
            padding: EdgeInsets.fromLTRB(
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacingMD.h,
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacing4XL.h,
            ),
            children: [
              const _MyDashboardSection(),
              SizedBox(height: AppDesignSystem.spacingLG.h),
              Text(
                'progress'.tr(),
                style: AppDesignSystem.h5.copyWith(
                  color: AppDesignSystem.neutral900,
                ),
              ),
              SizedBox(height: AppDesignSystem.spacingSM.h),
              ProgressTrendChart(
                title: 'weight'.tr(),
                unit: 'unit_kg'.tr(),
                points: weightPoints,
              ),
              SizedBox(height: AppDesignSystem.spacingMD.h),
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
                  AppCard(
                    margin: EdgeInsets.only(
                      bottom: AppDesignSystem.spacingSM.h,
                    ),
                    onTap: () => _openDetail(cubit, e),
                    child: Row(
                      children: [
                        Icon(
                          Icons.monitor_weight_outlined,
                          color: AppDesignSystem.primaryColor,
                          size: AppDesignSystem.iconSizeSM.sp,
                        ),
                        SizedBox(width: AppDesignSystem.spacingMD.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _fmtDate(e.date),
                                style: AppDesignSystem.bodyLarge.copyWith(
                                  color: AppDesignSystem.neutral900,
                                  fontWeight: AppDesignSystem.semiBold,
                                ),
                              ),
                              SizedBox(height: AppDesignSystem.spacing2XS.h),
                              Text(
                                (e.isCoachAuthored
                                        ? 'added_by_coach'
                                        : 'added_by_you')
                                    .tr(),
                                style: AppDesignSystem.labelSmall.copyWith(
                                  color: e.isCoachAuthored
                                      ? AppDesignSystem.infoColor
                                      : AppDesignSystem.neutral400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (e.weightKg != null)
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              end: AppDesignSystem.spacingSM.w,
                            ),
                            child: AppBadge(
                              text: '${_n(e.weightKg!)} ${'unit_kg'.tr()}',
                              variant: AppBadgeVariant.primary,
                              size: AppBadgeSize.small,
                            ),
                          ),
                        if (e.bodyFatPercent != null)
                          AppBadge(
                            text: '${_n(e.bodyFatPercent!)}%',
                            variant: AppBadgeVariant.info,
                            size: AppBadgeSize.small,
                          ),
                        Icon(
                          Icons.chevron_right,
                          color: AppDesignSystem.neutral400,
                          size: AppDesignSystem.iconSizeSM.sp,
                        ),
                      ],
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

/// The trainee's dashboard cards, loaded independently at the top of Progress.
class _MyDashboardSection extends StatelessWidget {
  const _MyDashboardSection();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyDashboardCubit>();
    return GetModel<TraineeDashboardModel>(
      useCaseCallBack: () => cubit.fetchSummary(),
      loadingWidget: SizedBox(
        height: 120.h,
        child: const Center(child: CircularProgressIndicator()),
      ),
      modelBuilder: (d) => DashboardCards(
        adherence: d.nutritionAdherence,
        completion: d.workoutCompletion,
      ),
    );
  }
}
