import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../repository/nutrition_plan_template_repository.dart';

class DeleteNutritionPlanTemplateParams extends BaseParams {
  final String id;

  DeleteNutritionPlanTemplateParams({required this.id});

  Map<String, dynamic> toJson() => <String, dynamic>{};
}

class DeleteNutritionPlanTemplateUsecase
    extends UseCase<String, DeleteNutritionPlanTemplateParams> {
  final NutritionPlanTemplateRepository repository;

  DeleteNutritionPlanTemplateUsecase(this.repository);

  @override
  Future<Result<String>> call({
    required DeleteNutritionPlanTemplateParams params,
  }) {
    return repository.deleteNutritionPlanTemplateRequest(id: params.id);
  }
}
