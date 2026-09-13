import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:meta/meta.dart';

import '../data/model/workout_plan_model.dart';
import '../data/params/create_update_workout_plan_params.dart';
import '../data/params/get_workout_plan_list_input.dart';
import '../data/repository/workout_plan_repository.dart';
import '../data/usecase/create_workout_plan_usecase.dart';
import '../data/usecase/delete_workout_plan_usecase.dart';
import '../data/usecase/get_workout_plan_list_usecase.dart';
import '../data/usecase/get_workout_plan_usecase.dart';
import '../data/usecase/set_active_workout_plan_usecase.dart';
import '../data/usecase/update_workout_plan_usecase.dart';

part 'workout_plan_state.dart';

/// Orchestrates the coach workout-plan feature. Holds the mutable save params
/// (built by the nested builder screen) and the list search/scope/filter state.
/// API methods return `Future<Result>` for the boilerplate widgets — no
/// `emit` for API state; only the search/filter setters emit (documented
/// list-UI exception).
class WorkoutPlanCubit extends Cubit<WorkoutPlanState> {
  WorkoutPlanCubit() : super(WorkoutPlanInitial());

  final WorkoutPlanRepository _repository = WorkoutPlanRepository();

  CreateUpdateWorkoutPlanParams saveParams = CreateUpdateWorkoutPlanParams();

  // ---- list scope / search / filter state -----------------------------------
  /// When set, the list is scoped to one trainee (and new plans inherit it).
  String? scopeTraineeId;
  String searchTerm = '';
  bool? filterActive;

  void setScopeTrainee(String? traineeId) => scopeTraineeId = traineeId;

  void setSearchTerm(String value) {
    searchTerm = value;
    emit(WorkoutPlanSearchChanged());
  }

  void setFilterActive(bool? value) {
    filterActive = value;
    emit(WorkoutPlanSearchChanged());
  }

  // ---- API operations (boilerplate-driven) ----------------------------------
  Future<Result> fetchWorkoutPlanList(dynamic data) async {
    return await GetWorkoutPlanListUsecase(_repository).call(
      params: GetWorkoutPlanListInput(
        request: data,
        traineeId: scopeTraineeId,
        filter: searchTerm.isNotEmpty ? searchTerm : null,
        isActive: filterActive,
      ),
    );
  }

  Future<Result> fetchWorkoutPlanById(String id) async {
    return await GetWorkoutPlanUsecase(
      _repository,
    ).call(params: GetWorkoutPlanParams(id: id));
  }

  Future<Result> createWorkoutPlan() async {
    return await CreateWorkoutPlanUsecase(_repository).call(params: saveParams);
  }

  Future<Result> updateWorkoutPlan() async {
    return await UpdateWorkoutPlanUsecase(_repository).call(params: saveParams);
  }

  Future<Result> deleteWorkoutPlan(String id) async {
    return await DeleteWorkoutPlanUsecase(
      _repository,
    ).call(params: DeleteWorkoutPlanParams(id: id));
  }

  Future<Result> setActiveWorkoutPlan(String id) async {
    return await SetActiveWorkoutPlanUsecase(
      _repository,
    ).call(params: SetActiveWorkoutPlanParams(id: id));
  }

  // ---- builder lifecycle helpers --------------------------------------------
  /// Reset [saveParams] for a fresh plan, seeding the trainee when the list is
  /// already scoped to one.
  void prepareCreate({String? traineeId}) => saveParams =
      CreateUpdateWorkoutPlanParams(traineeId: traineeId ?? scopeTraineeId ?? '');

  void prepareEdit(WorkoutPlanModel plan) =>
      saveParams = CreateUpdateWorkoutPlanParams.fromModel(plan);
}
