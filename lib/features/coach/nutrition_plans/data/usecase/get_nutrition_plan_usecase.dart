import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/nutrition_plan_model.dart';
import '../repository/nutrition_plan_repository.dart';

class GetNutritionPlanParams extends BaseParams {
  final String id;

  GetNutritionPlanParams({required this.id});

  Map<String, dynamic> toJson() => <String, dynamic>{};
}

class GetNutritionPlanUsecase
    extends UseCase<NutritionPlanModel, GetNutritionPlanParams> {
  final NutritionPlanRepository repository;

  GetNutritionPlanUsecase(this.repository);

  @override
  Future<Result<NutritionPlanModel>> call({
    required GetNutritionPlanParams params,
  }) {
    return repository.getNutritionPlanByIdRequest(id: params.id);
  }
}
