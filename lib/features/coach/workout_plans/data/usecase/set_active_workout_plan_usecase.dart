import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/workout_plan_model.dart';
import '../repository/workout_plan_repository.dart';

class SetActiveWorkoutPlanParams extends BaseParams {
  final String id;

  SetActiveWorkoutPlanParams({required this.id});

  Map<String, dynamic> toJson() => <String, dynamic>{};
}

class SetActiveWorkoutPlanUsecase
    extends UseCase<WorkoutPlanModel, SetActiveWorkoutPlanParams> {
  final WorkoutPlanRepository repository;

  SetActiveWorkoutPlanUsecase(this.repository);

  @override
  Future<Result<WorkoutPlanModel>> call({
    required SetActiveWorkoutPlanParams params,
  }) {
    return repository.setActiveWorkoutPlanRequest(id: params.id);
  }
}
