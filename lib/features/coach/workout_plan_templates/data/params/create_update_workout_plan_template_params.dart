import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_day_model.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_plan_model.dart';

/// Shared create/update payload for a workout plan **template**
/// (`CreateUpdateWorkoutPlanTemplateDto`). Identical to the plan write DTO but
/// **without `traineeId`/`isActive`** — a template is a reusable, trainee-less
/// blueprint. PUT is a **full replace** of the day/exercise tree, so always
/// resend the complete tree.
///
/// [id] only targets the update URL; it is not part of the body. Fields are
/// mutable so the builder can edit the header and swap the [days] tree in place.
/// The nested `days → exercises` write shape (no child ids — the server
/// regenerates them) is reused from the plan models' `toWriteJson`.
class CreateUpdateWorkoutPlanTemplateParams extends BaseParams {
  String id;
  String name;
  String? description;
  List<WorkoutDayModel> days;

  CreateUpdateWorkoutPlanTemplateParams({
    this.id = '',
    this.name = '',
    this.description,
    List<WorkoutDayModel>? days,
  }) : days = days ?? <WorkoutDayModel>[];

  factory CreateUpdateWorkoutPlanTemplateParams.fromModel(
    WorkoutPlanModel template,
  ) {
    return CreateUpdateWorkoutPlanTemplateParams(
      id: template.id ?? '',
      name: template.name ?? '',
      description: template.description,
      days: List<WorkoutDayModel>.from(template.days),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null && description!.trim().isNotEmpty)
        'description': description!.trim(),
      'days': [for (var i = 0; i < days.length; i++) days[i].toWriteJson(i)],
    };
  }
}
