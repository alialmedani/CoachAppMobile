import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';

import '../data/repository/my_nutrition_plan_repository.dart';
import '../data/usecase/get_my_nutrition_plan_usecase.dart';
import '../data/usecase/get_my_nutrition_plans_usecase.dart';

part 'my_nutrition_plan_state.dart';

/// Orchestrates the trainee's read-only nutrition-plan screens. Boilerplate
/// [GetModel] widgets own the async UI state; no `emit` for API state.
class MyNutritionPlanCubit extends Cubit<MyNutritionPlanState> {
  MyNutritionPlanCubit() : super(MyNutritionPlanInitial());

  final MyNutritionPlanRepository _repository = MyNutritionPlanRepository();

  Future<Result> fetchMyNutritionPlans() =>
      GetMyNutritionPlansUsecase(_repository).call(params: NoParams());

  Future<Result> fetchMyNutritionPlanById(String id) =>
      GetMyNutritionPlanUsecase(_repository).call(params: ByIdParams(id: id));
}
