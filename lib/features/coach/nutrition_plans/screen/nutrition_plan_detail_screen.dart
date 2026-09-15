import 'package:coachappmobile/core/boilerplate/get_model/cubits/get_model_cubit.dart';
import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/auth/constants/coachapp_permissions.dart';
import 'package:coachappmobile/features/auth/cubit/session_cubit.dart';
import 'package:coachappmobile/features/coach/nutrition_plan_templates/screen/widgets/save_nutrition_plan_as_template_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/nutrition_plan_cubit.dart';
import '../data/model/nutrition_plan_model.dart';
import 'nutrition_plan_builder_screen.dart';
import 'widgets/macro_summary_card.dart';
import 'widgets/nutrition_plan_viewer.dart';

/// Full read-only view of one nutrition plan (meals → items) with a macro
/// summary (server totals vs coach targets) and coach actions: edit and
/// set-active.
class NutritionPlanDetailScreen extends StatefulWidget {
  final String planId;

  const NutritionPlanDetailScreen({super.key, required this.planId});

  @override
  State<NutritionPlanDetailScreen> createState() =>
      _NutritionPlanDetailScreenState();
}

class _NutritionPlanDetailScreenState extends State<NutritionPlanDetailScreen> {
  GetModelCubit? _getModel;
  bool _changed = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NutritionPlanCubit>();
    final canSaveAsTemplate = context.read<SessionCubit>().can(
      CoachPermissions.nutritionPlanTemplatesCreate,
    );
    // System/gesture back must carry `_changed` back to the list (like the
    // leading button does) so the list refreshes after a set-active/edit;
    // a plain implicit pop returns null and would leave the list stale.
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _changed);
      },
      child: Scaffold(
        backgroundColor: AppDesignSystem.surfaceLight,
        appBar: AppTopBar(
          title: 'nutrition_plan_details'.tr(),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _changed),
          ),
        ),
        body: GetModel<NutritionPlanModel>(
          onCubitCreated: (c) => _getModel = c,
          useCaseCallBack: () => cubit.fetchNutritionPlanById(widget.planId),
          modelBuilder: (plan) => _Body(
            plan: plan,
            onEdit: () => _edit(cubit, plan),
            onSetActive: () => _setActive(cubit, plan),
            onSaveAsTemplate: canSaveAsTemplate
                ? () => _saveAsTemplate(plan)
                : null,
          ),
        ),
      ),
    );
  }

  Future<void> _saveAsTemplate(NutritionPlanModel plan) async {
    await showSaveNutritionPlanAsTemplateSheet(
      context,
      planId: plan.id ?? widget.planId,
      planName: plan.name ?? '',
    );
  }

  Future<void> _edit(NutritionPlanCubit cubit, NutritionPlanModel plan) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: NutritionPlanBuilderScreen(plan: plan),
        ),
      ),
    );
    if (result == true) {
      _changed = true;
      _getModel?.getModel();
    }
  }

  Future<void> _setActive(
    NutritionPlanCubit cubit,
    NutritionPlanModel plan,
  ) async {
    final result = await cubit.setActiveNutritionPlan(plan.id ?? widget.planId);
    if (!mounted) return;
    if (result.hasDataOnly) {
      _changed = true;
      _getModel?.getModel();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('plan_set_active'.tr()),
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
}

class _Body extends StatelessWidget {
  final NutritionPlanModel plan;
  final VoidCallback onEdit;
  final VoidCallback onSetActive;
  final VoidCallback? onSaveAsTemplate;

  const _Body({
    required this.plan,
    required this.onEdit,
    required this.onSetActive,
    this.onSaveAsTemplate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name ?? '',
                  style: AppDesignSystem.h4.copyWith(
                    color: AppDesignSystem.neutral900,
                  ),
                ),
                if ((plan.description ?? '').isNotEmpty) ...[
                  SizedBox(height: AppDesignSystem.spacingXS.h),
                  Text(
                    plan.description!,
                    style: AppDesignSystem.bodyMedium.copyWith(
                      color: AppDesignSystem.neutral600,
                      height: 1.5,
                    ),
                  ),
                ],
                SizedBox(height: AppDesignSystem.spacingMD.h),
                Wrap(
                  spacing: AppDesignSystem.spacingXS.w,
                  runSpacing: AppDesignSystem.spacingXS.h,
                  children: [
                    AppBadge(
                      text: (plan.isActive ? 'active' : 'inactive').tr(),
                      variant: plan.isActive
                          ? AppBadgeVariant.success
                          : AppBadgeVariant.neutral,
                      dot: true,
                    ),
                    AppBadge(
                      text: 'plan_meals_count'.tr(args: ['${plan.mealCount}']),
                      variant: AppBadgeVariant.info,
                      icon: Icons.restaurant_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppDesignSystem.spacingMD.h),
          MacroSummaryCard(
            calories: plan.totalCalories,
            proteinG: plan.totalProteinG,
            carbsG: plan.totalCarbsG,
            fatG: plan.totalFatG,
            targetCalories: plan.targetCalories,
            targetProteinG: plan.targetProteinG,
            targetCarbsG: plan.targetCarbsG,
            targetFatG: plan.targetFatG,
          ),
          // F16: make the "effective target" explicit. When the coach set no
          // explicit targets, the plan's own totals are what the trainee's
          // adherence is scored against — say so, so the coach isn't misled into
          // thinking there is no target.
          if (plan.targetCalories == null &&
              plan.targetProteinG == null &&
              plan.targetCarbsG == null &&
              plan.targetFatG == null) ...[
            SizedBox(height: AppDesignSystem.spacingSM.h),
            Container(
              padding: EdgeInsets.all(AppDesignSystem.spacingSM.w),
              decoration: BoxDecoration(
                color: AppDesignSystem.neutral100,
                borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
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
                      'nutrition_no_targets_note'.tr(),
                      style: AppDesignSystem.bodySmall.copyWith(
                        color: AppDesignSystem.neutral700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: AppDesignSystem.spacingMD.h),
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: AppDesignSystem.spacingXS.w,
              bottom: AppDesignSystem.spacingXS.h,
            ),
            child: Text(
              'meals'.tr(),
              style: AppDesignSystem.labelMedium.copyWith(
                color: AppDesignSystem.neutral500,
              ),
            ),
          ),
          NutritionPlanViewer(plan: plan),
          SizedBox(height: AppDesignSystem.spacingLG.h),
          AppButton(
            text: 'edit_nutrition_plan'.tr(),
            icon: Icons.edit_outlined,
            fullWidth: true,
            onPressed: onEdit,
          ),
          if (!plan.isActive) ...[
            SizedBox(height: AppDesignSystem.spacingSM.h),
            AppButton(
              text: 'set_active'.tr(),
              icon: Icons.flag_outlined,
              variant: AppButtonVariant.outline,
              fullWidth: true,
              onPressed: onSetActive,
            ),
          ],
          if (onSaveAsTemplate != null) ...[
            SizedBox(height: AppDesignSystem.spacingSM.h),
            AppButton(
              text: 'save_as_template'.tr(),
              icon: Icons.bookmark_add_outlined,
              variant: AppButtonVariant.ghost,
              fullWidth: true,
              onPressed: onSaveAsTemplate,
            ),
          ],
          SizedBox(height: AppDesignSystem.spacingXL.h),
        ],
      ),
    );
  }
}
