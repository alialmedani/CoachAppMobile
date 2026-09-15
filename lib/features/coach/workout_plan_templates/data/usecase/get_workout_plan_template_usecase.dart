import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_plan_model.dart';

import '../repository/workout_plan_template_repository.dart';

class GetWorkoutPlanTemplateParams extends BaseParams {
  final String id;

  GetWorkoutPlanTemplateParams({required this.id});

  Map<String, dynamic> toJson() => <String, dynamic>{};
}

class GetWorkoutPlanTemplateUsecase
    extends UseCase<WorkoutPlanModel, GetWorkoutPlanTemplateParams> {
  final WorkoutPlanTemplateRepository repository;

  GetWorkoutPlanTemplateUsecase(this.repository);

  @override
  Future<Result<WorkoutPlanModel>> call({
    required GetWorkoutPlanTemplateParams params,
  }) {
    return repository.getWorkoutPlanTemplateByIdRequest(id: params.id);
  }
}
