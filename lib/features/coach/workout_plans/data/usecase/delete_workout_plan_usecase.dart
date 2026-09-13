import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../repository/workout_plan_repository.dart';

class DeleteWorkoutPlanParams extends BaseParams {
  final String id;

  DeleteWorkoutPlanParams({required this.id});

  Map<String, dynamic> toJson() => <String, dynamic>{};
}

class DeleteWorkoutPlanUsecase extends UseCase<String, DeleteWorkoutPlanParams> {
  final WorkoutPlanRepository repository;

  DeleteWorkoutPlanUsecase(this.repository);

  @override
  Future<Result<String>> call({required DeleteWorkoutPlanParams params}) {
    return repository.deleteWorkoutPlanRequest(id: params.id);
  }
}
