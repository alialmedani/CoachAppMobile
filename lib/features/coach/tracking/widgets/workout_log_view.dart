import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/trainee/workout_logs/data/model/workout_log_model.dart';
import 'package:coachappmobile/features/trainee/workout_logs/screen/widgets/prescribed_vs_actual_row.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Read-only renderer for a [WorkoutLogModel]: a date header + each entry's
/// prescribed-vs-actual row. Reused by the coach's log detail (Phase 11) — and
/// available to any read-only workout-log surface. No actions.
class WorkoutLogView extends StatelessWidget {
  final WorkoutLogModel log;

  const WorkoutLogView({super.key, required this.log});

  static String _fmtDate(DateTime? d) {
    if (d == null) return '';
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        if (log.entries.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppDesignSystem.spacingXL.h,
            ),
            child: Text(
              'no_log_entries'.tr(),
              textAlign: TextAlign.center,
              style: AppDesignSystem.bodyMedium.copyWith(
                color: AppDesignSystem.neutral500,
              ),
            ),
          )
        else
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
      ],
    );
  }
}
