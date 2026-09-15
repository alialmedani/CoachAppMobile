import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';

import '../params/clone_nutrition_template_params.dart';
import '../repository/nutrition_plan_template_repository.dart';

class CloneNutritionTemplateUsecase
    extends UseCase<NutritionPlanModel, CloneNutritionTemplateParams> {
  final NutritionPlanTemplateRepository repository;

  CloneNutritionTemplateUsecase(this.repository);

  @override
  Future<Result<NutritionPlanModel>> call({
    required CloneNutritionTemplateParams params,
  }) {
    return repository.cloneToTraineeRequest(params: params);
  }
}
