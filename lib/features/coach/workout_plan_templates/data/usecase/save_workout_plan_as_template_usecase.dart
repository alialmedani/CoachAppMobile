import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_plan_model.dart';

import '../params/save_workout_plan_as_template_params.dart';
import '../repository/workout_plan_template_repository.dart';

class SaveWorkoutPlanAsTemplateUsecase
    extends UseCase<WorkoutPlanModel, SaveWorkoutPlanAsTemplateParams> {
  final WorkoutPlanTemplateRepository repository;

  SaveWorkoutPlanAsTemplateUsecase(this.repository);

  @override
  Future<Result<WorkoutPlanModel>> call({
    required SaveWorkoutPlanAsTemplateParams params,
  }) {
    return repository.saveAsTemplateRequest(params: params);
  }
}
