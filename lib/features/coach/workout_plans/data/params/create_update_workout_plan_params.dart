import 'package:coachappmobile/core/params/base_params.dart';

import '../model/workout_day_model.dart';
import '../model/workout_plan_model.dart';

/// Shared create/update payload for a workout plan (backend uses one
/// `CreateUpdateWorkoutPlanDto` for both POST and PUT — PUT is a **full
/// replace** of the day/exercise tree, so always resend the complete tree).
///
/// [id] only targets the update URL; it is not part of the body. Fields are
/// mutable so the builder can edit the header and swap the [days] tree in place.
/// [toJson] emits the nested `days → exercises` write shape with **no child
/// ids** (the server regenerates them) via each model's `toWriteJson`.
class CreateUpdateWorkoutPlanParams extends BaseParams {
  String id;
  String traineeId;
  String name;
  String? description;
  bool isActive;
  List<WorkoutDayModel> days;

  CreateUpdateWorkoutPlanParams({
    this.id = '',
    this.traineeId = '',
    this.name = '',
    this.description,
    this.isActive = false,
    List<WorkoutDayModel>? days,
  }) : days = days ?? <WorkoutDayModel>[];

  factory CreateUpdateWorkoutPlanParams.fromModel(WorkoutPlanModel plan) {
    return CreateUpdateWorkoutPlanParams(
      id: plan.id ?? '',
      traineeId: plan.traineeId ?? '',
      name: plan.name ?? '',
      description: plan.description,
      isActive: plan.isActive,
      days: List<WorkoutDayModel>.from(plan.days),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'traineeId': traineeId,
      'name': name,
      if (description != null && description!.trim().isNotEmpty)
        'description': description!.trim(),
      'isActive': isActive,
      'days': [for (var i = 0; i < days.length; i++) days[i].toWriteJson(i)],
    };
  }
}
