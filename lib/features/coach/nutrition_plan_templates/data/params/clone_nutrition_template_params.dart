import 'package:coachappmobile/core/params/base_params.dart';

/// Body for cloning a template onto a trainee (`CloneNutritionTemplateDto`).
///
/// [id] targets the custom action URL (`{url}/{id}/clone-to-trainee`) — it is
/// not part of the body. The server creates a new, **inactive** real nutrition
/// plan for [traineeId]; the optional [name]/[description] override the
/// template's (omitted here → the template's are used).
class CloneNutritionTemplateParams extends BaseParams {
  String id;
  String traineeId;
  String? name;
  String? description;

  CloneNutritionTemplateParams({
    this.id = '',
    this.traineeId = '',
    this.name,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'traineeId': traineeId,
      if (name != null && name!.trim().isNotEmpty) 'name': name!.trim(),
      if (description != null && description!.trim().isNotEmpty)
        'description': description!.trim(),
    };
  }
}
