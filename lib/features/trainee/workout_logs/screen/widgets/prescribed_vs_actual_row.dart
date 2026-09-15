import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/workout_log_model.dart';

/// Read-only display of a workout log entry's **prescribed** snapshot (the plan
/// target) and, when [showActual] is true, the trainee's **actual** performance
/// beside it. Manual (off-plan) entries have no prescribed snapshot — then only
/// the actual line renders.
class PrescribedVsActualRow extends StatelessWidget {
  final WorkoutLogEntryModel entry;
  final bool showActual;

  const PrescribedVsActualRow({
    super.key,
    required this.entry,
    this.showActual = true,
  });

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  String _line({
    required int? sets,
    required String? reps,
    required double? weightKg,
  }) {
    final parts = <String>[];
    if (sets != null) {
      parts.add(
        reps != null && reps.isNotEmpty
            ? 'sets_x_reps'.tr(args: ['$sets', reps])
            : 'sets_count'.tr(args: ['$sets']),
      );
    }
    if (weightKg != null) parts.add('${_trim(weightKg)} ${'unit_kg'.tr()}');
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entry.hasPrescribed)
          _MetricLine(
            label: 'prescribed'.tr(),
            value: _line(
              sets: entry.prescribedSets,
              reps: entry.prescribedReps,
              weightKg: entry.prescribedWeightKg,
            ),
            variant: AppBadgeVariant.neutral,
          ),
        if (showActual) ...[
          if (entry.hasPrescribed)
            SizedBox(height: AppDesignSystem.spacing2XS.h),
          _MetricLine(
            label: 'actual'.tr(),
            value: _line(
              sets: entry.sets,
              reps: entry.reps,
              weightKg: entry.weightKg,
            ),
            variant: AppBadgeVariant.primary,
          ),
        ],
      ],
    );
  }
}

class _MetricLine extends StatelessWidget {
  final String label;
  final String value;
  final AppBadgeVariant variant;

  const _MetricLine({
    required this.label,
    required this.value,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppBadge(text: label, variant: variant, size: AppBadgeSize.small),
        SizedBox(width: AppDesignSystem.spacingXS.w),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: AppDesignSystem.bodySmall.copyWith(
              color: AppDesignSystem.neutral700,
            ),
          ),
        ),
      ],
    );
  }
}
