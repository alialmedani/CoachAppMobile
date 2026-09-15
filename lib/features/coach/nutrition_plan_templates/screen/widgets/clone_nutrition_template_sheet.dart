import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/features/coach/workout_plans/screen/widgets/trainee_picker_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../cubit/nutrition_plan_template_cubit.dart';

/// Clones a nutrition template onto a coach-picked trainee.
///
/// Opens the shared trainee picker, asks for confirmation, then calls
/// [NutritionPlanTemplateCubit.cloneToTrainee]. The new plan inherits the
/// template's name/description and starts **inactive**. Returns `true` when a
/// plan was created (so a host can react, e.g. toast/refresh).
Future<bool> showCloneNutritionTemplateSheet(
  BuildContext context, {
  required NutritionPlanTemplateCubit cubit,
  required String templateId,
  required String templateName,
}) async {
  final trainee = await showTraineePickerSheet(context);
  if (trainee == null || !context.mounted) return false;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('use_for_trainee'.tr()),
      content: Text(
        'clone_to_trainee_confirm'.tr(args: [templateName, trainee.fullName]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('cancel'.tr()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('confirm'.tr()),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return false;

  final result = await cubit.cloneToTrainee(templateId, trainee.id ?? '');
  if (!context.mounted) return false;

  if (result.hasDataOnly) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('plan_created_from_template'.tr()),
        backgroundColor: AppDesignSystem.successColor,
      ),
    );
    return true;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(result.error ?? 'something_went_wrong'.tr()),
      backgroundColor: AppDesignSystem.errorColor,
    ),
  );
  return false;
}
