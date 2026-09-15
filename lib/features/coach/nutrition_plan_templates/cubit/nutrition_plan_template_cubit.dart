import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';
import 'package:meta/meta.dart';

import '../data/params/clone_nutrition_template_params.dart';
import '../data/params/create_update_nutrition_plan_template_params.dart';
import '../data/params/get_nutrition_plan_template_list_input.dart';
import '../data/params/save_nutrition_plan_as_template_params.dart';
import '../data/repository/nutrition_plan_template_repository.dart';
import '../data/usecase/clone_nutrition_template_usecase.dart';
import '../data/usecase/create_nutrition_plan_template_usecase.dart';
import '../data/usecase/delete_nutrition_plan_template_usecase.dart';
import '../data/usecase/get_nutrition_plan_template_list_usecase.dart';
import '../data/usecase/get_nutrition_plan_template_usecase.dart';
import '../data/usecase/save_nutrition_plan_as_template_usecase.dart';
import '../data/usecase/update_nutrition_plan_template_usecase.dart';

part 'nutrition_plan_template_state.dart';

/// Orchestrates the coach nutrition-plan-template feature. Holds the mutable save
/// params (built by the nested builder screen) and the list search term. API
/// methods return `Future<Result>` for the boilerplate widgets — no `emit` for
/// API state; only the search setter emits (documented list-UI exception).
class NutritionPlanTemplateCubit extends Cubit<NutritionPlanTemplateState> {
  NutritionPlanTemplateCubit() : super(NutritionPlanTemplateInitial());

  final NutritionPlanTemplateRepository _repository =
      NutritionPlanTemplateRepository();

  CreateUpdateNutritionPlanTemplateParams saveParams =
      CreateUpdateNutritionPlanTemplateParams();

  // ---- list search state ----------------------------------------------------
  String searchTerm = '';

  void setSearchTerm(String value) {
    searchTerm = value;
    emit(NutritionPlanTemplateSearchChanged());
  }

  // ---- API operations (boilerplate-driven) ----------------------------------
  Future<Result> fetchTemplateList(dynamic data) async {
    return await GetNutritionPlanTemplateListUsecase(_repository).call(
      params: GetNutritionPlanTemplateListInput(
        request: data,
        filter: searchTerm.isNotEmpty ? searchTerm : null,
      ),
    );
  }

  Future<Result> fetchTemplateById(String id) async {
    return await GetNutritionPlanTemplateUsecase(
      _repository,
    ).call(params: GetNutritionPlanTemplateParams(id: id));
  }

  Future<Result> createTemplate() async {
    return await CreateNutritionPlanTemplateUsecase(
      _repository,
    ).call(params: saveParams);
  }

  Future<Result> updateTemplate() async {
    return await UpdateNutritionPlanTemplateUsecase(
      _repository,
    ).call(params: saveParams);
  }

  Future<Result> deleteTemplate(String id) async {
    return await DeleteNutritionPlanTemplateUsecase(
      _repository,
    ).call(params: DeleteNutritionPlanTemplateParams(id: id));
  }

  /// Clones [templateId] onto [traineeId] as a new, inactive real nutrition plan
  /// (the plan inherits the template's name/description).
  Future<Result> cloneToTrainee(String templateId, String traineeId) async {
    return await CloneNutritionTemplateUsecase(_repository).call(
      params: CloneNutritionTemplateParams(
        id: templateId,
        traineeId: traineeId,
      ),
    );
  }

  /// Snapshots an existing trainee nutrition plan into a new template.
  Future<Result> saveAsTemplate(
    String planId,
    String name,
    String? description,
  ) async {
    return await SaveNutritionPlanAsTemplateUsecase(_repository).call(
      params: SaveNutritionPlanAsTemplateParams(
        nutritionPlanId: planId,
        name: name,
        description: description,
      ),
    );
  }

  // ---- builder lifecycle helpers --------------------------------------------
  /// Reset [saveParams] for a fresh template.
  void prepareCreate() =>
      saveParams = CreateUpdateNutritionPlanTemplateParams();

  void prepareEdit(NutritionPlanModel template) =>
      saveParams = CreateUpdateNutritionPlanTemplateParams.fromModel(template);
}
