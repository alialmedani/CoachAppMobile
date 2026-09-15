import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/tracking/data/model/progress_entry_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/my_progress_cubit.dart';
import 'my_progress_editor_screen.dart';

/// Read-only detail for one of the trainee's progress entries. Shows the
/// measurements and who authored it; **edit and delete are offered only for
/// trainee-authored entries** (`isCoachAuthored == false`) — coach-authored
/// entries are read-only. Returns `true` when the entry was edited or deleted so
/// the list can refresh.
class MyProgressDetailScreen extends StatefulWidget {
  final ProgressEntryModel entry;

  const MyProgressDetailScreen({super.key, required this.entry});

  @override
  State<MyProgressDetailScreen> createState() => _MyProgressDetailScreenState();
}

class _MyProgressDetailScreenState extends State<MyProgressDetailScreen> {
  bool _changed = false;

  ProgressEntryModel get e => widget.entry;

  static String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  static String _num(double? v, String unit) {
    if (v == null) return '—';
    final n = v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    return '$n $unit';
  }

  Future<void> _edit() async {
    final cubit = context.read<MyProgressCubit>();
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: MyProgressEditorScreen(entry: e),
        ),
      ),
    );
    if (result == true && mounted) {
      _changed = true;
      Navigator.pop(context, true);
    }
  }

  Future<void> _delete() async {
    final cubit = context.read<MyProgressCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete_progress'.tr()),
        content: Text('delete_progress_confirm'.tr()),
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
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final result = await cubit.deleteEntry(e.id ?? '');
    if (!mounted) return;
    if (result.hasDataOnly) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('progress_deleted'.tr()),
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

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      if (e.weightKg != null)
        _MeasureRow(label: 'weight_kg'.tr(), value: _num(e.weightKg, 'unit_kg'.tr())),
      if (e.bodyFatPercent != null)
        _MeasureRow(label: 'body_fat_percent'.tr(), value: _num(e.bodyFatPercent, '%')),
      if (e.chestCm != null)
        _MeasureRow(label: 'chest_cm'.tr(), value: _num(e.chestCm, 'unit_cm'.tr())),
      if (e.waistCm != null)
        _MeasureRow(label: 'waist_cm'.tr(), value: _num(e.waistCm, 'unit_cm'.tr())),
      if (e.hipsCm != null)
        _MeasureRow(label: 'hips_cm'.tr(), value: _num(e.hipsCm, 'unit_cm'.tr())),
      if (e.armCm != null)
        _MeasureRow(label: 'arm_cm'.tr(), value: _num(e.armCm, 'unit_cm'.tr())),
      if (e.thighCm != null)
        _MeasureRow(label: 'thigh_cm'.tr(), value: _num(e.thighCm, 'unit_cm'.tr())),
    ];
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _changed);
      },
      child: Scaffold(
        backgroundColor: AppDesignSystem.surfaceLight,
        appBar: AppTopBar(
          title: 'progress_detail'.tr(),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _changed),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: AppDesignSystem.iconSizeSM.sp,
                      color: AppDesignSystem.primaryColor,
                    ),
                    SizedBox(width: AppDesignSystem.spacingMD.w),
                    Expanded(
                      child: Text(
                        _fmtDate(e.date),
                        style: AppDesignSystem.h5.copyWith(
                          color: AppDesignSystem.neutral900,
                        ),
                      ),
                    ),
                    AppBadge(
                      text: (e.isCoachAuthored ? 'added_by_coach' : 'added_by_you')
                          .tr(),
                      variant: e.isCoachAuthored
                          ? AppBadgeVariant.info
                          : AppBadgeVariant.primary,
                      size: AppBadgeSize.small,
                      icon: e.isCoachAuthored
                          ? Icons.sports_outlined
                          : Icons.person_outline,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDesignSystem.spacingMD.h),
              if (rows.isEmpty)
                AppCard(
                  child: Text(
                    'no_measurements_recorded'.tr(),
                    style: AppDesignSystem.bodyMedium.copyWith(
                      color: AppDesignSystem.neutral500,
                    ),
                  ),
                )
              else
                AppCard(
                  child: Column(
                    children: [
                      for (var i = 0; i < rows.length; i++) ...[
                        rows[i],
                        if (i < rows.length - 1)
                          Divider(
                            height: AppDesignSystem.spacingLG.h,
                            color: AppDesignSystem.neutral100,
                          ),
                      ],
                    ],
                  ),
                ),
              if ((e.notes ?? '').isNotEmpty) ...[
                SizedBox(height: AppDesignSystem.spacingMD.h),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'notes'.tr(),
                        style: AppDesignSystem.labelMedium.copyWith(
                          color: AppDesignSystem.neutral500,
                        ),
                      ),
                      SizedBox(height: AppDesignSystem.spacing2XS.h),
                      Text(
                        e.notes!,
                        style: AppDesignSystem.bodyMedium.copyWith(
                          color: AppDesignSystem.neutral900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: AppDesignSystem.spacingLG.h),
              if (e.isCoachAuthored)
                Container(
                  padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
                  decoration: BoxDecoration(
                    color: AppDesignSystem.infoColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(
                      AppDesignSystem.radiusMD.r,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: AppDesignSystem.iconSizeSM.sp,
                        color: AppDesignSystem.infoColor,
                      ),
                      SizedBox(width: AppDesignSystem.spacingSM.w),
                      Expanded(
                        child: Text(
                          'coach_entry_readonly'.tr(),
                          style: AppDesignSystem.bodySmall.copyWith(
                            color: AppDesignSystem.neutral700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                AppButton(
                  text: 'edit_progress'.tr(),
                  icon: Icons.edit_outlined,
                  fullWidth: true,
                  onPressed: _edit,
                ),
                SizedBox(height: AppDesignSystem.spacingSM.h),
                AppButton(
                  text: 'delete_progress'.tr(),
                  icon: Icons.delete_outline,
                  variant: AppButtonVariant.danger,
                  fullWidth: true,
                  onPressed: _delete,
                ),
              ],
              SizedBox(height: AppDesignSystem.spacingXL.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeasureRow extends StatelessWidget {
  final String label;
  final String value;

  const _MeasureRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppDesignSystem.bodyMedium.copyWith(
              color: AppDesignSystem.neutral600,
            ),
          ),
        ),
        Text(
          value,
          style: AppDesignSystem.bodyMedium.copyWith(
            color: AppDesignSystem.neutral900,
            fontWeight: AppDesignSystem.semiBold,
          ),
        ),
      ],
    );
  }
}
