import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';

import '../repository/nutrition_plan_template_repository.dart';

class GetNutritionPlanTemplateParams extends BaseParams {
  final String id;

  GetNutritionPlanTemplateParams({required this.id});

  Map<String, dynamic> toJson() => <String, dynamic>{};
}

class GetNutritionPlanTemplateUsecase
    extends UseCase<NutritionPlanModel, GetNutritionPlanTemplateParams> {
  final NutritionPlanTemplateRepository repository;

  GetNutritionPlanTemplateUsecase(this.repository);

  @override
  Future<Result<NutritionPlanModel>> call({
    required GetNutritionPlanTemplateParams params,
  }) {
    return repository.getNutritionPlanTemplateByIdRequest(id: params.id);
  }
}
