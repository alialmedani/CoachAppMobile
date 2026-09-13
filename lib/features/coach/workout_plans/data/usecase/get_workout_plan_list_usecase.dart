import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/workout_plan_model.dart';
import '../params/get_workout_plan_list_input.dart';
import '../repository/workout_plan_repository.dart';

class GetWorkoutPlanListUsecase
    extends UseCase<List<WorkoutPlanModel>, GetWorkoutPlanListInput> {
  final WorkoutPlanRepository repository;

  GetWorkoutPlanListUsecase(this.repository);

  @override
  Future<Result<List<WorkoutPlanModel>>> call({
    required GetWorkoutPlanListInput params,
  }) {
    return repository.getWorkoutPlanListRequest(params: params);
  }
}
