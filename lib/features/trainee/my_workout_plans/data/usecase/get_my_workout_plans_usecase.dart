import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_plan_model.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';

import '../repository/my_workout_plan_repository.dart';

/// Fetch the trainee's own workout plans (unpaged summary list).
class GetMyWorkoutPlansUsecase
    extends UseCase<List<WorkoutPlanModel>, NoParams> {
  final MyWorkoutPlanRepository repository;

  GetMyWorkoutPlansUsecase(this.repository);

  @override
  Future<Result<List<WorkoutPlanModel>>> call({required NoParams params}) {
    return repository.getMyWorkoutPlansRequest();
  }
}
