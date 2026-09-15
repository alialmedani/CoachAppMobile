import 'package:coachappmobile/core/params/base_params.dart';

/// Body for snapshotting an existing trainee nutrition plan into a new reusable
/// template (`SaveNutritionPlanAsTemplateDto`).
///
/// [nutritionPlanId] is the source plan; [name] (required) and optional
/// [description] name the new template.
class SaveNutritionPlanAsTemplateParams extends BaseParams {
  String nutritionPlanId;
  String name;
  String? description;

  SaveNutritionPlanAsTemplateParams({
    this.nutritionPlanId = '',
    this.name = '',
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'nutritionPlanId': nutritionPlanId,
      'name': name,
      if (description != null && description!.trim().isNotEmpty)
        'description': description!.trim(),
    };
  }
}
