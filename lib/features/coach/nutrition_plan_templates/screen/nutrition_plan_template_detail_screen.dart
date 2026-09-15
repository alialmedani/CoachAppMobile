import 'package:coachappmobile/core/boilerplate/get_model/cubits/get_model_cubit.dart';
import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/auth/constants/coachapp_permissions.dart';
import 'package:coachappmobile/features/auth/cubit/session_cubit.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/screen/widgets/macro_summary_card.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/screen/widgets/nutrition_plan_viewer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/nutrition_plan_template_cubit.dart';
import 'widgets/clone_nutrition_template_sheet.dart';
import 'nutrition_plan_template_builder_screen.dart';

/// Full read-only view of one nutrition template (meals → items) with a macro
/// summary (server totals vs coach targets) and coach actions: edit, delete and
/// "use for a trainee" (clone), each gated by the coach's granted permissions.
class NutritionPlanTemplateDetailScreen extends StatefulWidget {
  final String templateId;

  const NutritionPlanTemplateDetailScreen({
    super.key,
    required this.templateId,
  });

  @override
  State<NutritionPlanTemplateDetailScreen> createState() =>
      _NutritionPlanTemplateDetailScreenState();
}

class _NutritionPlanTemplateDetailScreenState
    extends State<NutritionPlanTemplateDetailScreen> {
  GetModelCubit? _getModel;
  bool _changed = false;

  /// The currently loaded template, captured in [GetModel.modelBuilder] so the
  /// app-bar actions (clone/delete) can read its name without re-fetching.
  NutritionPlanModel? _template;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NutritionPlanTemplateCubit>();
    final session = context.read<SessionCubit>();
    final canEdit = session.can(CoachPermissions.nutritionPlanTemplatesUpdate);
    final canDelete = session.can(
      CoachPermissions.nutritionPlanTemplatesDelete,
    );
    final canClone = session.can(CoachPermissions.nutritionPlansCreate);

    // System/gesture back must carry `_changed` back to the list (like the
    // leading button does) so the list refreshes after an edit/delete; a plain
    // implicit pop returns null and would leave the list stale.
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _changed);
      },
      child: Scaffold(
        backgroundColor: AppDesignSystem.surfaceLight,
        appBar: AppTopBar(
          title: 'template_details'.tr(),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _changed),
          ),
          actions: [
            if (canClone)
              IconButton(
                tooltip: 'use_for_trainee'.tr(),
                icon: const Icon(Icons.person_add_alt_outlined),
                onPressed: () => _clone(cubit, template: _template),
              ),
            if (canDelete)
              IconButton(
                tooltip: 'delete_template'.tr(),
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(cubit),
              ),
          ],
        ),
        body: GetModel<NutritionPlanModel>(
          onCubitCreated: (c) => _getModel = c,
          useCaseCallBack: () => cubit.fetchTemplateById(widget.templateId),
          modelBuilder: (template) {
            _template = template;
            return _Body(
              template: template,
              canEdit: canEdit,
              canClone: canClone,
              onEdit: () => _edit(cubit, template),
              onClone: () => _clone(cubit, template: template),
            );
          },
        ),
      ),
    );
  }

  Future<void> _edit(
    NutritionPlanTemplateCubit cubit,
    NutritionPlanModel template,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: NutritionPlanTemplateBuilderScreen(template: template),
        ),
      ),
    );
    if (result == true) {
      _changed = true;
      _getModel?.getModel();
    }
  }

  Future<void> _clone(
    NutritionPlanTemplateCubit cubit, {
    NutritionPlanModel? template,
  }) async {
    await showCloneNutritionTemplateSheet(
      context,
      cubit: cubit,
      templateId: template?.id ?? widget.templateId,
      templateName: template?.name ?? '',
    );
  }

  Future<void> _confirmDelete(NutritionPlanTemplateCubit cubit) async {
    final name = _template?.name ?? '';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete_template'.tr()),
        content: Text('delete_template_confirm'.tr(args: [name])),
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
    final result = await cubit.deleteTemplate(widget.templateId);
    if (!mounted) return;
    if (result.hasDataOnly) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('template_deleted'.tr()),
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
  final NutritionPlanModel template;
  final bool canEdit;
  final bool canClone;
  final VoidCallback onEdit;
  final VoidCallback onClone;

  const _Body({
    required this.template,
    required this.canEdit,
    required this.canClone,
    required this.onEdit,
    required this.onClone,
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
                  template.name ?? '',
                  style: AppDesignSystem.h4.copyWith(
                    color: AppDesignSystem.neutral900,
                  ),
                ),
                if ((template.description ?? '').isNotEmpty) ...[
                  SizedBox(height: AppDesignSystem.spacingXS.h),
                  Text(
                    template.description!,
                    style: AppDesignSystem.bodyMedium.copyWith(
                      color: AppDesignSystem.neutral600,
                      height: 1.5,
                    ),
                  ),
                ],
                SizedBox(height: AppDesignSystem.spacingMD.h),
                AppBadge(
                  text: 'plan_meals_count'.tr(args: ['${template.mealCount}']),
                  variant: AppBadgeVariant.info,
                  icon: Icons.restaurant_outlined,
                ),
              ],
            ),
          ),
          SizedBox(height: AppDesignSystem.spacingMD.h),
          MacroSummaryCard(
            calories: template.totalCalories,
            proteinG: template.totalProteinG,
            carbsG: template.totalCarbsG,
            fatG: template.totalFatG,
            targetCalories: template.targetCalories,
            targetProteinG: template.targetProteinG,
            targetCarbsG: template.targetCarbsG,
            targetFatG: template.targetFatG,
          ),
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
          NutritionPlanViewer(plan: template),
          SizedBox(height: AppDesignSystem.spacingLG.h),
          if (canClone) ...[
            AppButton(
              text: 'use_for_trainee'.tr(),
              icon: Icons.person_add_alt_outlined,
              fullWidth: true,
              onPressed: onClone,
            ),
            SizedBox(height: AppDesignSystem.spacingSM.h),
          ],
          if (canEdit)
            AppButton(
              text: 'edit_template'.tr(),
              icon: Icons.edit_outlined,
              variant: AppButtonVariant.outline,
              fullWidth: true,
              onPressed: onEdit,
            ),
          SizedBox(height: AppDesignSystem.spacingXL.h),
        ],
      ),
    );
  }
}
