import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_plan_model.dart';

import '../params/create_update_workout_plan_template_params.dart';
import '../repository/workout_plan_template_repository.dart';

class CreateWorkoutPlanTemplateUsecase
    extends UseCase<WorkoutPlanModel, CreateUpdateWorkoutPlanTemplateParams> {
  final WorkoutPlanTemplateRepository repository;

  CreateWorkoutPlanTemplateUsecase(this.repository);

  @override
  Future<Result<WorkoutPlanModel>> call({
    required CreateUpdateWorkoutPlanTemplateParams params,
  }) {
    return repository.createWorkoutPlanTemplateRequest(params: params);
  }
}
