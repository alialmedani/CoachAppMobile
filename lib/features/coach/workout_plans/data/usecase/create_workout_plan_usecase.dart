import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/workout_plan_model.dart';
import '../params/create_update_workout_plan_params.dart';
import '../repository/workout_plan_repository.dart';

class CreateWorkoutPlanUsecase
    extends UseCase<WorkoutPlanModel, CreateUpdateWorkoutPlanParams> {
  final WorkoutPlanRepository repository;

  CreateWorkoutPlanUsecase(this.repository);

  @override
  Future<Result<WorkoutPlanModel>> call({
    required CreateUpdateWorkoutPlanParams params,
  }) {
    return repository.createWorkoutPlanRequest(params: params);
  }
}
