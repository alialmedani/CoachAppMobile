import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_plan_model.dart';

import '../params/get_workout_plan_template_list_input.dart';
import '../repository/workout_plan_template_repository.dart';

class GetWorkoutPlanTemplateListUsecase
    extends UseCase<List<WorkoutPlanModel>, GetWorkoutPlanTemplateListInput> {
  final WorkoutPlanTemplateRepository repository;

  GetWorkoutPlanTemplateListUsecase(this.repository);

  @override
  Future<Result<List<WorkoutPlanModel>>> call({
    required GetWorkoutPlanTemplateListInput params,
  }) {
    return repository.getWorkoutPlanTemplateListRequest(params: params);
  }
}
