import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/meal_model.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';

/// Shared create/update payload for a nutrition plan **template**
/// (`CreateUpdateNutritionPlanTemplateDto`). Identical to the plan write DTO but
/// **without `traineeId`/`isActive`** — a template is a reusable, trainee-less
/// blueprint. PUT is a **full replace** of the meal/item tree, so always resend
/// the complete tree.
///
/// [id] only targets the update URL; it is not part of the body. Fields are
/// mutable so the builder can edit the header, the optional targets and swap the
/// [meals] tree in place. [toJson] emits the nested `meals → items` write shape
/// with **no child ids** and **no computed macros** (each item serializes to
/// only `foodId`/`order`/`quantity`, reused from the plan models' `toWriteJson`).
/// The optional target fields are **omitted when null** so the template's meal
/// totals act as the effective targets.
class CreateUpdateNutritionPlanTemplateParams extends BaseParams {
  String id;
  String name;
  String? description;
  double? targetCalories;
  double? targetProteinG;
  double? targetCarbsG;
  double? targetFatG;
  List<MealModel> meals;

  CreateUpdateNutritionPlanTemplateParams({
    this.id = '',
    this.name = '',
    this.description,
    this.targetCalories,
    this.targetProteinG,
    this.targetCarbsG,
    this.targetFatG,
    List<MealModel>? meals,
  }) : meals = meals ?? <MealModel>[];

  factory CreateUpdateNutritionPlanTemplateParams.fromModel(
    NutritionPlanModel template,
  ) {
    return CreateUpdateNutritionPlanTemplateParams(
      id: template.id ?? '',
      name: template.name ?? '',
      description: template.description,
      targetCalories: template.targetCalories,
      targetProteinG: template.targetProteinG,
      targetCarbsG: template.targetCarbsG,
      targetFatG: template.targetFatG,
      meals: List<MealModel>.from(template.meals),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null && description!.trim().isNotEmpty)
        'description': description!.trim(),
      if (targetCalories != null) 'targetCalories': targetCalories,
      if (targetProteinG != null) 'targetProteinG': targetProteinG,
      if (targetCarbsG != null) 'targetCarbsG': targetCarbsG,
      if (targetFatG != null) 'targetFatG': targetFatG,
      'meals': [for (var i = 0; i < meals.length; i++) meals[i].toWriteJson(i)],
    };
  }
}
