import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';

import '../params/create_update_nutrition_plan_template_params.dart';
import '../repository/nutrition_plan_template_repository.dart';

class CreateNutritionPlanTemplateUsecase
    extends UseCase<NutritionPlanModel, CreateUpdateNutritionPlanTemplateParams> {
  final NutritionPlanTemplateRepository repository;

  CreateNutritionPlanTemplateUsecase(this.repository);

  @override
  Future<Result<NutritionPlanModel>> call({
    required CreateUpdateNutritionPlanTemplateParams params,
  }) {
    return repository.createNutritionPlanTemplateRequest(params: params);
  }
}
