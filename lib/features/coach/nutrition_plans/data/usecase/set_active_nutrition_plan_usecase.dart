import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/nutrition_plan_model.dart';
import '../repository/nutrition_plan_repository.dart';

class SetActiveNutritionPlanParams extends BaseParams {
  final String id;

  SetActiveNutritionPlanParams({required this.id});

  Map<String, dynamic> toJson() => <String, dynamic>{};
}

class SetActiveNutritionPlanUsecase
    extends UseCase<NutritionPlanModel, SetActiveNutritionPlanParams> {
  final NutritionPlanRepository repository;

  SetActiveNutritionPlanUsecase(this.repository);

  @override
  Future<Result<NutritionPlanModel>> call({
    required SetActiveNutritionPlanParams params,
  }) {
    return repository.setActiveNutritionPlanRequest(id: params.id);
  }
}
