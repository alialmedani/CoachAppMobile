import 'package:coachappmobile/core/params/base_params.dart';

import '../model/meal_model.dart';
import '../model/nutrition_plan_model.dart';

/// Shared create/update payload for a nutrition plan (backend uses one
/// `CreateUpdateNutritionPlanDto` for both POST and PUT — PUT is a **full
/// replace** of the meal/item tree, so always resend the complete tree).
///
/// [id] only targets the update URL; it is not part of the body. Fields are
/// mutable so the builder can edit the header, the optional targets and swap the
/// [meals] tree in place. [toJson] emits the nested `meals → items` write shape
/// with **no child ids** and **no computed macros** (each item serializes to
/// only `foodId`/`order`/`quantity`). The optional target fields are **omitted
/// when null** so the plan's meal totals act as the effective targets.
class CreateUpdateNutritionPlanParams extends BaseParams {
  String id;
  String traineeId;
  String name;
  String? description;
  bool isActive;
  double? targetCalories;
  double? targetProteinG;
  double? targetCarbsG;
  double? targetFatG;
  List<MealModel> meals;

  CreateUpdateNutritionPlanParams({
    this.id = '',
    this.traineeId = '',
    this.name = '',
    this.description,
    this.isActive = false,
    this.targetCalories,
    this.targetProteinG,
    this.targetCarbsG,
    this.targetFatG,
    List<MealModel>? meals,
  }) : meals = meals ?? <MealModel>[];

  factory CreateUpdateNutritionPlanParams.fromModel(NutritionPlanModel plan) {
    return CreateUpdateNutritionPlanParams(
      id: plan.id ?? '',
      traineeId: plan.traineeId ?? '',
      name: plan.name ?? '',
      description: plan.description,
      isActive: plan.isActive,
      targetCalories: plan.targetCalories,
      targetProteinG: plan.targetProteinG,
      targetCarbsG: plan.targetCarbsG,
      targetFatG: plan.targetFatG,
      meals: List<MealModel>.from(plan.meals),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'traineeId': traineeId,
      'name': name,
      if (description != null && description!.trim().isNotEmpty)
        'description': description!.trim(),
      'isActive': isActive,
      if (targetCalories != null) 'targetCalories': targetCalories,
      if (targetProteinG != null) 'targetProteinG': targetProteinG,
      if (targetCarbsG != null) 'targetCarbsG': targetCarbsG,
      if (targetFatG != null) 'targetFatG': targetFatG,
      'meals': [for (var i = 0; i < meals.length; i++) meals[i].toWriteJson(i)],
    };
  }
}
