import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/workout_plan_model.dart';
import '../repository/workout_plan_repository.dart';

class GetWorkoutPlanParams extends BaseParams {
  final String id;

  GetWorkoutPlanParams({required this.id});

  Map<String, dynamic> toJson() => <String, dynamic>{};
}

class GetWorkoutPlanUsecase
    extends UseCase<WorkoutPlanModel, GetWorkoutPlanParams> {
  final WorkoutPlanRepository repository;

  GetWorkoutPlanUsecase(this.repository);

  @override
  Future<Result<WorkoutPlanModel>> call({
    required GetWorkoutPlanParams params,
  }) {
    return repository.getWorkoutPlanByIdRequest(id: params.id);
  }
}
