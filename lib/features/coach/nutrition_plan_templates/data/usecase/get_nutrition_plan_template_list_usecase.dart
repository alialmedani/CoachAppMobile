import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';

import '../params/get_nutrition_plan_template_list_input.dart';
import '../repository/nutrition_plan_template_repository.dart';

class GetNutritionPlanTemplateListUsecase
    extends
        UseCase<List<NutritionPlanModel>, GetNutritionPlanTemplateListInput> {
  final NutritionPlanTemplateRepository repository;

  GetNutritionPlanTemplateListUsecase(this.repository);

  @override
  Future<Result<List<NutritionPlanModel>>> call({
    required GetNutritionPlanTemplateListInput params,
  }) {
    return repository.getNutritionPlanTemplateListRequest(params: params);
  }
}
