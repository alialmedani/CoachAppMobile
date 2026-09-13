import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';

import '../repository/my_nutrition_plan_repository.dart';

/// Fetch the trainee's own nutrition plans (unpaged summary list).
class GetMyNutritionPlansUsecase
    extends UseCase<List<NutritionPlanModel>, NoParams> {
  final MyNutritionPlanRepository repository;

  GetMyNutritionPlansUsecase(this.repository);

  @override
  Future<Result<List<NutritionPlanModel>>> call({required NoParams params}) {
    return repository.getMyNutritionPlansRequest();
  }
}
