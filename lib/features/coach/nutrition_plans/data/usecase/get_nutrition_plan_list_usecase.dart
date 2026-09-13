import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/nutrition_plan_model.dart';
import '../params/get_nutrition_plan_list_input.dart';
import '../repository/nutrition_plan_repository.dart';

class GetNutritionPlanListUsecase
    extends UseCase<List<NutritionPlanModel>, GetNutritionPlanListInput> {
  final NutritionPlanRepository repository;

  GetNutritionPlanListUsecase(this.repository);

  @override
  Future<Result<List<NutritionPlanModel>>> call({
    required GetNutritionPlanListInput params,
  }) {
    return repository.getNutritionPlanListRequest(params: params);
  }
}
