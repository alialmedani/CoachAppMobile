import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/screen/widgets/macro_summary_card.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/screen/widgets/serving_display.dart';
import 'package:coachappmobile/features/trainee/nutrition_logs/data/model/nutrition_log_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Read-only renderer for a [NutritionLogModel]: authoritative server totals
/// ([MacroSummaryCard]) + each logged item with its computed calories. Reused
/// by the coach's log detail (Phase 11). No actions.
class NutritionLogView extends StatelessWidget {
  final NutritionLogModel log;

  const NutritionLogView({super.key, required this.log});

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MacroSummaryCard(
          calories: log.totalCalories,
          proteinG: log.totalProteinG,
          carbsG: log.totalCarbsG,
          fatG: log.totalFatG,
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.foodName ?? 'meal_item_entry'.tr(),
                          style: AppDesignSystem.bodyLarge.copyWith(
                            color: AppDesignSystem.neutral900,
                            fontWeight: AppDesignSystem.semiBold,
                          ),
                        ),
                        SizedBox(height: AppDesignSystem.spacing2XS.h),
                        Text(
                          ServingDisplay.full(
                            e.quantity,
                            e.servingSize,
                            e.servingUnit,
                          ),
                          style: AppDesignSystem.bodySmall.copyWith(
                            color: AppDesignSystem.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'macro_calories_kcal'.tr(args: [_n(e.calories)]),
                    style: AppDesignSystem.labelMedium.copyWith(
                      color: AppDesignSystem.accentDark,
                      fontWeight: AppDesignSystem.semiBold,
                    ),
                  ),
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
