import 'package:coachappmobile/core/boilerplate/get_model/cubits/get_model_cubit.dart';
import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/workout_log_cubit.dart';
import '../data/model/workout_log_model.dart';
import 'widgets/prescribed_vs_actual_row.dart';
import 'workout_log_editor_screen.dart';

/// Read-only view of one workout log: each entry's prescribed snapshot vs the
/// trainee's actuals. Offers edit (opens the editor) and delete.
class WorkoutLogViewScreen extends StatefulWidget {
  final String logId;

  const WorkoutLogViewScreen({super.key, required this.logId});

  @override
  State<WorkoutLogViewScreen> createState() => _WorkoutLogViewScreenState();
}

class _WorkoutLogViewScreenState extends State<WorkoutLogViewScreen> {
  GetModelCubit? _getModel;
  bool _changed = false;

  static String _fmtDate(DateTime? d) {
    if (d == null) return '';
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  Future<void> _edit(WorkoutLogCubit cubit, WorkoutLogModel log) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: WorkoutLogEditorScreen(log: log),
        ),
      ),
    );
    if (result == true) {
      _changed = true;
      _getModel?.getModel();
    }
  }

  Future<void> _delete(WorkoutLogCubit cubit, WorkoutLogModel log) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete_workout_log'.tr()),
        content: Text('delete_workout_log_confirm'.tr()),
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
    final result = await cubit.deleteLog(log.id ?? widget.logId);
    if (!mounted) return;
    if (result.hasDataOnly) {
      Navigator.pop(context, true); // deleted → tell Today to refresh
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('workout_log_deleted'.tr()),
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
    final cubit = context.read<WorkoutLogCubit>();
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _changed);
      },
      child: Scaffold(
        backgroundColor: AppDesignSystem.surfaceLight,
        appBar: AppTopBar(
          title: 'workout_log'.tr(),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _changed),
          ),
        ),
        body: GetModel<WorkoutLogModel>(
          onCubitCreated: (c) => _getModel = c,
          useCaseCallBack: () => cubit.fetchLog(widget.logId),
          modelBuilder: (log) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_outlined,
                        color: AppDesignSystem.primaryColor,
                        size: AppDesignSystem.iconSizeSM.sp,
                      ),
                      SizedBox(width: AppDesignSystem.spacingSM.w),
                      Text(
                        _fmtDate(log.date),
                        style: AppDesignSystem.bodyLarge.copyWith(
                          color: AppDesignSystem.neutral900,
                          fontWeight: AppDesignSystem.semiBold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacingMD.h),
                for (final e in log.entries) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.exerciseName ?? 'exercise_entry'.tr(),
                          style: AppDesignSystem.bodyLarge.copyWith(
                            color: AppDesignSystem.neutral900,
                            fontWeight: AppDesignSystem.semiBold,
                          ),
                        ),
                        SizedBox(height: AppDesignSystem.spacingXS.h),
                        PrescribedVsActualRow(entry: e),
                      ],
                    ),
                  ),
                  SizedBox(height: AppDesignSystem.spacingSM.h),
                ],
                if ((log.notes ?? '').isNotEmpty) ...[
                  SizedBox(height: AppDesignSystem.spacingXS.h),
                  Text(
                    log.notes!,
                    style: AppDesignSystem.bodyMedium.copyWith(
                      color: AppDesignSystem.neutral600,
                    ),
                  ),
                ],
                SizedBox(height: AppDesignSystem.spacingLG.h),
                AppButton(
                  text: 'edit_log'.tr(),
                  icon: Icons.edit_outlined,
                  fullWidth: true,
                  onPressed: () => _edit(cubit, log),
                ),
                SizedBox(height: AppDesignSystem.spacingSM.h),
                AppButton(
                  text: 'delete_log'.tr(),
                  icon: Icons.delete_outline,
                  variant: AppButtonVariant.danger,
                  fullWidth: true,
                  onPressed: () => _delete(cubit, log),
                ),
                SizedBox(height: AppDesignSystem.spacingXL.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
