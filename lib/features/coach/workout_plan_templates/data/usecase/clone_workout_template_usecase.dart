import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_plan_model.dart';

import '../params/clone_workout_template_params.dart';
import '../repository/workout_plan_template_repository.dart';

class CloneWorkoutTemplateUsecase
    extends UseCase<WorkoutPlanModel, CloneWorkoutTemplateParams> {
  final WorkoutPlanTemplateRepository repository;

  CloneWorkoutTemplateUsecase(this.repository);

  @override
  Future<Result<WorkoutPlanModel>> call({
    required CloneWorkoutTemplateParams params,
  }) {
    return repository.cloneToTraineeRequest(params: params);
  }
}
