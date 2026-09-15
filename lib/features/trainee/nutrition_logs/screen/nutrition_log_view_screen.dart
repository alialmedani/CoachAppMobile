import 'package:coachappmobile/core/boilerplate/get_model/cubits/get_model_cubit.dart';
import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/screen/widgets/macro_summary_card.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/screen/widgets/serving_display.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/nutrition_log_cubit.dart';
import '../data/model/nutrition_log_model.dart';
import 'nutrition_log_editor_screen.dart';

/// Read-only view of one nutrition log: server-computed totals + logged items.
/// Offers edit (opens the editor) and delete.
class NutritionLogViewScreen extends StatefulWidget {
  final String logId;

  const NutritionLogViewScreen({super.key, required this.logId});

  @override
  State<NutritionLogViewScreen> createState() => _NutritionLogViewScreenState();
}

class _NutritionLogViewScreenState extends State<NutritionLogViewScreen> {
  GetModelCubit? _getModel;
  bool _changed = false;

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  Future<void> _edit(NutritionLogCubit cubit, NutritionLogModel log) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: NutritionLogEditorScreen(log: log),
        ),
      ),
    );
    if (result == true) {
      _changed = true;
      _getModel?.getModel();
    }
  }

  Future<void> _delete(NutritionLogCubit cubit, NutritionLogModel log) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete_nutrition_log'.tr()),
        content: Text('delete_nutrition_log_confirm'.tr()),
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
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('nutrition_log_deleted'.tr()),
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
    final cubit = context.read<NutritionLogCubit>();
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _changed);
      },
      child: Scaffold(
        backgroundColor: AppDesignSystem.surfaceLight,
        appBar: AppTopBar(
          title: 'nutrition_log'.tr(),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _changed),
          ),
        ),
        body: GetModel<NutritionLogModel>(
          onCubitCreated: (c) => _getModel = c,
          useCaseCallBack: () => cubit.fetchLog(widget.logId),
          modelBuilder: (log) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MacroSummaryCard(
                  calories: log.totalCalories,
                  proteinG: log.totalProteinG,
                  carbsG: log.totalCarbsG,
                  fatG: log.totalFatG,
                ),
                SizedBox(height: AppDesignSystem.spacingMD.h),
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
