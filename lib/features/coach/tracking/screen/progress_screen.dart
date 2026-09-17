import 'package:coachappmobile/core/boilerplate/get_model/cubits/get_model_cubit.dart';
import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/constant/app_icons/app_icons.dart';
import 'package:coachappmobile/core/ui/shapes/chamfer.dart';
import 'package:coachappmobile/core/ui/widgets/app_icon.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/auth/constants/coachapp_permissions.dart';
import 'package:coachappmobile/features/auth/cubit/session_cubit.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/progress_cubit.dart';
import '../data/model/progress_entry_model.dart';
import '../widgets/progress_trend_chart.dart';
import 'progress_editor_screen.dart';

/// Coach view of a trainee's progress: a weight trend chart + the entry list,
/// with add / edit / delete.
class ProgressScreen extends StatefulWidget {
  final String traineeId;
  final String? traineeName;

  const ProgressScreen({super.key, required this.traineeId, this.traineeName});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
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

  Future<void> _openEditor(
    ProgressCubit cubit, {
    ProgressEntryModel? entry,
  }) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: ProgressEditorScreen(entry: entry),
        ),
      ),
    );
    if (changed == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProgressCubit>()..setTrainee(widget.traineeId);
    // F8: only offer "Add" when the coach holds the granular create permission.
    final canCreate =
        context.read<SessionCubit>().can(CoachPermissions.progressCreate);
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceCanvas,
      appBar: AppTopBar(title: 'progress'.tr(), subtitle: widget.traineeName),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              heroTag: 'fab_progress',
              onPressed: () => _openEditor(cubit),
              backgroundColor: AppDesignSystem.primaryColor,
              foregroundColor: AppDesignSystem.onPrimary,
              shape: const ChamferBorder(cut: 16),
              icon: AppIcon(
                AppIcons.plus,
                size: AppDesignSystem.iconSizeSM,
                color: AppDesignSystem.onPrimary,
              ),
              label: Text('add_progress'.tr()),
            )
          : null,
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
              ProgressTrendChart(
                title: 'weight'.tr(),
                unit: 'unit_kg'.tr(),
                points: weightPoints,
              ),
              SizedBox(height: AppDesignSystem.spacingLG.h),
              if (entries.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: AppDesignSystem.spacingXL.h),
                  child: AppEmptyState(
                    icon: Icons.insights_outlined,
                    title: 'no_progress_entries'.tr(),
                    subtitle: 'no_progress_entries_subtitle'.tr(),
                    iconColor: AppDesignSystem.primaryColor,
                  ),
                )
              else
                for (final e in entries)
                  _EntryRow(
                    date: _fmtDate(e.date),
                    weight: e.weightKg == null
                        ? null
                        : '${_n(e.weightKg!)} ${'unit_kg'.tr()}',
                    bodyFat: e.bodyFatPercent == null
                        ? null
                        : '${_n(e.bodyFatPercent!)}%',
                    onTap: () => _openEditor(cubit, entry: e),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final String date;
  final String? weight;
  final String? bodyFat;
  final VoidCallback onTap;

  const _EntryRow({
    required this.date,
    required this.weight,
    required this.bodyFat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: AppDesignSystem.spacingSM.h),
      onTap: onTap,
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
            child: Icon(
              Icons.monitor_weight_outlined,
              color: AppDesignSystem.primaryStrong,
              size: AppDesignSystem.iconSizeSM.sp,
            ),
          ),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                date,
                style: AppDesignSystem.bodyLarge.copyWith(
                  color: AppDesignSystem.textPrimary,
                  fontWeight: AppDesignSystem.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          if (weight != null)
            Padding(
              padding: EdgeInsetsDirectional.only(
                end: AppDesignSystem.spacingSM.w,
              ),
              child: AppBadge(
                text: weight!,
                variant: AppBadgeVariant.primary,
                size: AppBadgeSize.small,
              ),
            ),
          if (bodyFat != null)
            AppBadge(
              text: bodyFat!,
              variant: AppBadgeVariant.info,
              size: AppBadgeSize.small,
            ),
        ],
      ),
    );
  }
}
