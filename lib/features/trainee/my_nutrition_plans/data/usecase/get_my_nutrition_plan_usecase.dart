import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';

import '../repository/my_nutrition_plan_repository.dart';

/// Fetch one of the trainee's nutrition plans as a full tree by id.
class GetMyNutritionPlanUsecase
    extends UseCase<NutritionPlanModel, ByIdParams> {
  final MyNutritionPlanRepository repository;

  GetMyNutritionPlanUsecase(this.repository);

  @override
  Future<Result<NutritionPlanModel>> call({required ByIdParams params}) {
    return repository.getMyNutritionPlanByIdRequest(id: params.id);
  }
}
