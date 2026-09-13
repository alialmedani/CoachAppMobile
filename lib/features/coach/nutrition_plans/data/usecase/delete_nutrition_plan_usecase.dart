import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../repository/nutrition_plan_repository.dart';

class DeleteNutritionPlanParams extends BaseParams {
  final String id;

  DeleteNutritionPlanParams({required this.id});

  Map<String, dynamic> toJson() => <String, dynamic>{};
}

class DeleteNutritionPlanUsecase
    extends UseCase<String, DeleteNutritionPlanParams> {
  final NutritionPlanRepository repository;

  DeleteNutritionPlanUsecase(this.repository);

  @override
  Future<Result<String>> call({required DeleteNutritionPlanParams params}) {
    return repository.deleteNutritionPlanRequest(id: params.id);
  }
}
