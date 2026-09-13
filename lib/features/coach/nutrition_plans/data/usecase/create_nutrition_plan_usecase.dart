import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/nutrition_plan_model.dart';
import '../params/create_update_nutrition_plan_params.dart';
import '../repository/nutrition_plan_repository.dart';

class CreateNutritionPlanUsecase
    extends UseCase<NutritionPlanModel, CreateUpdateNutritionPlanParams> {
  final NutritionPlanRepository repository;

  CreateNutritionPlanUsecase(this.repository);

  @override
  Future<Result<NutritionPlanModel>> call({
    required CreateUpdateNutritionPlanParams params,
  }) {
    return repository.createNutritionPlanRequest(params: params);
  }
}
