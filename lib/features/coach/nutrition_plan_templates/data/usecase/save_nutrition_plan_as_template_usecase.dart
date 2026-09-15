import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';

import '../params/save_nutrition_plan_as_template_params.dart';
import '../repository/nutrition_plan_template_repository.dart';

class SaveNutritionPlanAsTemplateUsecase
    extends UseCase<NutritionPlanModel, SaveNutritionPlanAsTemplateParams> {
  final NutritionPlanTemplateRepository repository;

  SaveNutritionPlanAsTemplateUsecase(this.repository);

  @override
  Future<Result<NutritionPlanModel>> call({
    required SaveNutritionPlanAsTemplateParams params,
  }) {
    return repository.saveAsTemplateRequest(params: params);
  }
}
