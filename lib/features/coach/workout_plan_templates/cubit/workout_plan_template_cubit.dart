import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_plan_model.dart';
import 'package:meta/meta.dart';

import '../data/params/clone_workout_template_params.dart';
import '../data/params/create_update_workout_plan_template_params.dart';
import '../data/params/get_workout_plan_template_list_input.dart';
import '../data/params/save_workout_plan_as_template_params.dart';
import '../data/repository/workout_plan_template_repository.dart';
import '../data/usecase/clone_workout_template_usecase.dart';
import '../data/usecase/create_workout_plan_template_usecase.dart';
import '../data/usecase/delete_workout_plan_template_usecase.dart';
import '../data/usecase/get_workout_plan_template_list_usecase.dart';
import '../data/usecase/get_workout_plan_template_usecase.dart';
import '../data/usecase/save_workout_plan_as_template_usecase.dart';
import '../data/usecase/update_workout_plan_template_usecase.dart';

part 'workout_plan_template_state.dart';

/// Orchestrates the coach workout-plan-template feature. Holds the mutable save
/// params (built by the nested builder screen) and the list search term. API
/// methods return `Future<Result>` for the boilerplate widgets — no `emit` for
/// API state; only the search setter emits (documented list-UI exception).
class WorkoutPlanTemplateCubit extends Cubit<WorkoutPlanTemplateState> {
  WorkoutPlanTemplateCubit() : super(WorkoutPlanTemplateInitial());

  final WorkoutPlanTemplateRepository _repository =
      WorkoutPlanTemplateRepository();

  CreateUpdateWorkoutPlanTemplateParams saveParams =
      CreateUpdateWorkoutPlanTemplateParams();

  // ---- list search state ----------------------------------------------------
  String searchTerm = '';

  void setSearchTerm(String value) {
    searchTerm = value;
    emit(WorkoutPlanTemplateSearchChanged());
  }

  // ---- API operations (boilerplate-driven) ----------------------------------
  Future<Result> fetchTemplateList(dynamic data) async {
    return await GetWorkoutPlanTemplateListUsecase(_repository).call(
      params: GetWorkoutPlanTemplateListInput(
        request: data,
        filter: searchTerm.isNotEmpty ? searchTerm : null,
      ),
    );
  }

  Future<Result> fetchTemplateById(String id) async {
    return await GetWorkoutPlanTemplateUsecase(
      _repository,
    ).call(params: GetWorkoutPlanTemplateParams(id: id));
  }

  Future<Result> createTemplate() async {
    return await CreateWorkoutPlanTemplateUsecase(
      _repository,
    ).call(params: saveParams);
  }

  Future<Result> updateTemplate() async {
    return await UpdateWorkoutPlanTemplateUsecase(
      _repository,
    ).call(params: saveParams);
  }

  Future<Result> deleteTemplate(String id) async {
    return await DeleteWorkoutPlanTemplateUsecase(
      _repository,
    ).call(params: DeleteWorkoutPlanTemplateParams(id: id));
  }

  /// Clones [templateId] onto [traineeId] as a new, inactive real workout plan
  /// (the plan inherits the template's name/description).
  Future<Result> cloneToTrainee(String templateId, String traineeId) async {
    return await CloneWorkoutTemplateUsecase(_repository).call(
      params: CloneWorkoutTemplateParams(id: templateId, traineeId: traineeId),
    );
  }

  /// Snapshots an existing trainee workout plan into a new template.
  Future<Result> saveAsTemplate(
    String planId,
    String name,
    String? description,
  ) async {
    return await SaveWorkoutPlanAsTemplateUsecase(_repository).call(
      params: SaveWorkoutPlanAsTemplateParams(
        workoutPlanId: planId,
        name: name,
        description: description,
      ),
    );
  }

  // ---- builder lifecycle helpers --------------------------------------------
  /// Reset [saveParams] for a fresh template.
  void prepareCreate() =>
      saveParams = CreateUpdateWorkoutPlanTemplateParams();

  void prepareEdit(WorkoutPlanModel template) =>
      saveParams = CreateUpdateWorkoutPlanTemplateParams.fromModel(template);
}
