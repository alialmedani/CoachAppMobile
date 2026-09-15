import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../repository/workout_plan_template_repository.dart';

class DeleteWorkoutPlanTemplateParams extends BaseParams {
  final String id;

  DeleteWorkoutPlanTemplateParams({required this.id});

  Map<String, dynamic> toJson() => <String, dynamic>{};
}

class DeleteWorkoutPlanTemplateUsecase
    extends UseCase<String, DeleteWorkoutPlanTemplateParams> {
  final WorkoutPlanTemplateRepository repository;

  DeleteWorkoutPlanTemplateUsecase(this.repository);

  @override
  Future<Result<String>> call({
    required DeleteWorkoutPlanTemplateParams params,
  }) {
    return repository.deleteWorkoutPlanTemplateRequest(id: params.id);
  }
}
