import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Self-contained macro summary card, reused by the plan detail (server totals)
/// and the builder (live client estimate).
///
/// Renders total calories prominently plus protein / carbs / fat with the macro
/// colour coding. When a target is set for a macro it draws a consumed-vs-target
/// bar visually capped at 100% but labelled with the true percentage. When
/// [isEstimate] is true it labels the figures as a client-side estimate (the
/// server totals returned after save are authoritative).
class MacroSummaryCard extends StatelessWidget {
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double? targetCalories;
  final double? targetProteinG;
  final double? targetCarbsG;
  final double? targetFatG;
  final bool isEstimate;

  const MacroSummaryCard({
    super.key,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.targetCalories,
    this.targetProteinG,
    this.targetCarbsG,
    this.targetFatG,
    this.isEstimate = false,
  });

  // Macro colour coding (sourced from the design system, never hardcoded hex).
  static const Color _caloriesColor = AppDesignSystem.accentColor;
  static const Color _proteinColor = AppDesignSystem.infoColor;
  static const Color _carbsColor = AppDesignSystem.warningColor;
  static const Color _fatColor = AppDesignSystem.successColor;

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  (isEstimate ? 'macro_estimate' : 'macro_totals').tr(),
                  style: AppDesignSystem.h6.copyWith(
                    color: AppDesignSystem.neutral900,
                  ),
                ),
              ),
              if (isEstimate)
                AppBadge(
                  text: 'estimate'.tr(),
                  variant: AppBadgeVariant.warning,
                  size: AppBadgeSize.small,
                  icon: Icons.calculate_outlined,
                ),
            ],
          ),
          if (isEstimate) ...[
            SizedBox(height: AppDesignSystem.spacing2XS.h),
            Text(
              'macro_estimate_note'.tr(),
              style: AppDesignSystem.bodySmall.copyWith(
                color: AppDesignSystem.neutral500,
              ),
            ),
          ],
          SizedBox(height: AppDesignSystem.spacingMD.h),
          _CaloriesRow(
            value: calories,
            target: targetCalories,
            color: _caloriesColor,
          ),
          SizedBox(height: AppDesignSystem.spacingMD.h),
          _MacroLine(
            label: 'protein'.tr(),
            value: proteinG,
            target: targetProteinG,
            color: _proteinColor,
          ),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          _MacroLine(
            label: 'carbs'.tr(),
            value: carbsG,
            target: targetCarbsG,
            color: _carbsColor,
          ),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          _MacroLine(
            label: 'fat'.tr(),
            value: fatG,
            target: targetFatG,
            color: _fatColor,
          ),
        ],
      ),
    );
  }
}

class _CaloriesRow extends StatelessWidget {
  final double value;
  final double? target;
  final Color color;

  const _CaloriesRow({
    required this.value,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = target;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(
              Icons.local_fire_department_outlined,
              size: AppDesignSystem.iconSizeSM.sp,
              color: color,
            ),
            SizedBox(width: AppDesignSystem.spacingXS.w),
            Text(
              MacroSummaryCard._n(value),
              style: AppDesignSystem.h3.copyWith(color: color),
            ),
            SizedBox(width: AppDesignSystem.spacingXS.w),
            Padding(
              padding: EdgeInsets.only(bottom: AppDesignSystem.spacingXS.h),
              child: Text(
                'kcal'.tr(),
                style: AppDesignSystem.bodySmall.copyWith(
                  color: AppDesignSystem.neutral500,
                ),
              ),
            ),
            const Spacer(),
            if (t != null && t > 0)
              Padding(
                padding: EdgeInsets.only(bottom: AppDesignSystem.spacingXS.h),
                child: Text(
                  'macro_of_target_kcal'.tr(
                    args: [MacroSummaryCard._n(t), _pct(value, t)],
                  ),
                  style: AppDesignSystem.labelMedium.copyWith(
                    color: AppDesignSystem.neutral600,
                  ),
                ),
              ),
          ],
        ),
        if (t != null && t > 0) ...[
          SizedBox(height: AppDesignSystem.spacingXS.h),
          _Bar(value: value, target: t, color: color),
        ],
      ],
    );
  }
}

class _MacroLine extends StatelessWidget {
  final String label;
  final double value;
  final double? target;
  final Color color;

  const _MacroLine({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = target;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: AppDesignSystem.spacingXS.w),
            Expanded(
              child: Text(
                label,
                style: AppDesignSystem.bodyMedium.copyWith(
                  color: AppDesignSystem.neutral700,
                ),
              ),
            ),
            Text(
              t != null && t > 0
                  ? 'macro_of_target_g'.tr(
                      args: [
                        MacroSummaryCard._n(value),
                        MacroSummaryCard._n(t),
                        _pct(value, t),
                      ],
                    )
                  : 'macro_value_g'.tr(args: [MacroSummaryCard._n(value)]),
              style: AppDesignSystem.labelMedium.copyWith(
                color: AppDesignSystem.neutral900,
                fontWeight: AppDesignSystem.semiBold,
              ),
            ),
          ],
        ),
        if (t != null && t > 0) ...[
          SizedBox(height: AppDesignSystem.spacingXS.h),
          _Bar(value: value, target: t, color: color),
        ],
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double value;
  final double target;
  final Color color;

  const _Bar({required this.value, required this.target, required this.color});

  @override
  Widget build(BuildContext context) {
    final fraction = target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull.r),
      child: LinearProgressIndicator(
        value: fraction,
        minHeight: 6.h,
        backgroundColor: AppDesignSystem.neutral200,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

String _pct(double value, double target) {
  if (target <= 0) return '0';
  return (value / target * 100).round().toString();
}
