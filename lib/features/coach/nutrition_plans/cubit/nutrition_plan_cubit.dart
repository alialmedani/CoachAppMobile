import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:meta/meta.dart';

import '../data/model/nutrition_plan_model.dart';
import '../data/params/create_update_nutrition_plan_params.dart';
import '../data/params/get_nutrition_plan_list_input.dart';
import '../data/repository/nutrition_plan_repository.dart';
import '../data/usecase/create_nutrition_plan_usecase.dart';
import '../data/usecase/delete_nutrition_plan_usecase.dart';
import '../data/usecase/get_nutrition_plan_list_usecase.dart';
import '../data/usecase/get_nutrition_plan_usecase.dart';
import '../data/usecase/set_active_nutrition_plan_usecase.dart';
import '../data/usecase/update_nutrition_plan_usecase.dart';

part 'nutrition_plan_state.dart';

/// Orchestrates the coach nutrition-plan feature. Holds the mutable save params
/// (built by the nested builder screen) and the list search/scope/filter state.
/// API methods return `Future<Result>` for the boilerplate widgets — no
/// `emit` for API state; only the search/filter setters emit (documented
/// list-UI exception).
class NutritionPlanCubit extends Cubit<NutritionPlanState> {
  NutritionPlanCubit() : super(NutritionPlanInitial());

  final NutritionPlanRepository _repository = NutritionPlanRepository();

  CreateUpdateNutritionPlanParams saveParams =
      CreateUpdateNutritionPlanParams();

  // ---- list scope / search / filter state -----------------------------------
  /// When set, the list is scoped to one trainee (and new plans inherit it).
  String? scopeTraineeId;
  String searchTerm = '';
  bool? filterActive;

  void setScopeTrainee(String? traineeId) => scopeTraineeId = traineeId;

  void setSearchTerm(String value) {
    searchTerm = value;
    emit(NutritionPlanSearchChanged());
  }

  void setFilterActive(bool? value) {
    filterActive = value;
    emit(NutritionPlanSearchChanged());
  }

  // ---- API operations (boilerplate-driven) ----------------------------------
  Future<Result> fetchNutritionPlanList(dynamic data) async {
    return await GetNutritionPlanListUsecase(_repository).call(
      params: GetNutritionPlanListInput(
        request: data,
        traineeId: scopeTraineeId,
        filter: searchTerm.isNotEmpty ? searchTerm : null,
        isActive: filterActive,
      ),
    );
  }

  Future<Result> fetchNutritionPlanById(String id) async {
    return await GetNutritionPlanUsecase(
      _repository,
    ).call(params: GetNutritionPlanParams(id: id));
  }

  Future<Result> createNutritionPlan() async {
    return await CreateNutritionPlanUsecase(
      _repository,
    ).call(params: saveParams);
  }

  Future<Result> updateNutritionPlan() async {
    return await UpdateNutritionPlanUsecase(
      _repository,
    ).call(params: saveParams);
  }

  Future<Result> deleteNutritionPlan(String id) async {
    return await DeleteNutritionPlanUsecase(
      _repository,
    ).call(params: DeleteNutritionPlanParams(id: id));
  }

  Future<Result> setActiveNutritionPlan(String id) async {
    return await SetActiveNutritionPlanUsecase(
      _repository,
    ).call(params: SetActiveNutritionPlanParams(id: id));
  }

  // ---- builder lifecycle helpers --------------------------------------------
  /// Reset [saveParams] for a fresh plan, seeding the trainee when the list is
  /// already scoped to one.
  void prepareCreate({String? traineeId}) =>
      saveParams = CreateUpdateNutritionPlanParams(
        traineeId: traineeId ?? scopeTraineeId ?? '',
      );

  void prepareEdit(NutritionPlanModel plan) =>
      saveParams = CreateUpdateNutritionPlanParams.fromModel(plan);
}
