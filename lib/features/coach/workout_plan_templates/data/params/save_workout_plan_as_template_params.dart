import 'package:coachappmobile/core/params/base_params.dart';

/// Body for snapshotting an existing trainee workout plan into a new reusable
/// template (`SaveWorkoutPlanAsTemplateDto`).
///
/// [workoutPlanId] is the source plan; [name] (required) and optional
/// [description] name the new template.
class SaveWorkoutPlanAsTemplateParams extends BaseParams {
  String workoutPlanId;
  String name;
  String? description;

  SaveWorkoutPlanAsTemplateParams({
    this.workoutPlanId = '',
    this.name = '',
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'workoutPlanId': workoutPlanId,
      'name': name,
      if (description != null && description!.trim().isNotEmpty)
        'description': description!.trim(),
    };
  }
}
