import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:meta/meta.dart';

import '../data/model/trainee_model.dart';
import '../data/repository/trainee_repository.dart';
import '../data/usecase/create_trainee_usecase.dart';
import '../data/usecase/delete_trainee_usecase.dart';
import '../data/usecase/get_trainee_list_usecase.dart';
import '../data/usecase/get_trainee_usecase.dart';
import '../data/usecase/reset_trainee_password_usecase.dart';
import '../data/usecase/update_trainee_usecase.dart';

part 'trainee_state.dart';

/// Orchestrates the coach "Trainees" feature. Holds mutable params for the
/// create/edit/reset forms and the list search/filter state. API methods return
/// `Future<Result>` for the boilerplate widgets (no `emit` for API state); only
/// the search/filter setters emit (documented list-UI exception).
class TraineeCubit extends Cubit<TraineeState> {
  TraineeCubit() : super(TraineeInitial());

  final TraineeRepository _repository = TraineeRepository();

  CreateTraineeParams createTraineeParams = CreateTraineeParams();
  UpdateTraineeParams updateTraineeParams = UpdateTraineeParams();
  ResetTraineePasswordParams resetPasswordParams = ResetTraineePasswordParams();

  // ---- list search / filter state -------------------------------------------
  String searchTerm = '';
  int? filterGoal;

  /// Roster defaults to ACTIVE trainees; deactivated trainees move under the
  /// "Inactive" filter (null = "All"). See PD10/F19 (recoverable deactivation).
  bool? filterActive = true;

  bool get hasActiveFilters =>
      searchTerm.isNotEmpty || filterGoal != null || filterActive != null;

  void setSearchTerm(String value) {
    searchTerm = value;
    emit(TraineeSearchChanged());
  }

  void setFilterGoal(int? value) {
    filterGoal = value;
    emit(TraineeSearchChanged());
  }

  void setFilterActive(bool? value) {
    filterActive = value;
    emit(TraineeSearchChanged());
  }

  void clearFilters() {
    searchTerm = '';
    filterGoal = null;
    filterActive = null;
    emit(TraineeSearchChanged());
  }

  // ---- API operations (boilerplate-driven) ----------------------------------
  Future<Result> fetchTraineeList(dynamic data) async {
    return await GetTraineeListUsecase(_repository).call(
      params: GetTraineeListParams(
        request: data,
        filter: searchTerm.isNotEmpty ? searchTerm : null,
        goal: filterGoal,
        isActive: filterActive,
      ),
    );
  }

  Future<Result> fetchTraineeById(String id) async {
    return await GetTraineeUsecase(_repository).call(
      params: GetTraineeParams(id: id),
    );
  }

  Future<Result> createTrainee() async {
    return await CreateTraineeUsecase(_repository).call(
      params: createTraineeParams,
    );
  }

  Future<Result> updateTrainee() async {
    return await UpdateTraineeUsecase(_repository).call(
      params: updateTraineeParams,
    );
  }

  Future<Result> deleteTrainee(String id) async {
    return await DeleteTraineeUsecase(_repository).call(
      params: DeleteTraineeParams(id: id),
    );
  }

  Future<Result> resetPassword() async {
    return await ResetTraineePasswordUsecase(_repository).call(
      params: resetPasswordParams,
    );
  }

  // ---- form lifecycle helpers -----------------------------------------------
  void prepareCreate() => createTraineeParams = CreateTraineeParams();

  void prepareEdit(TraineeModel trainee) =>
      updateTraineeParams = UpdateTraineeParams.fromModel(trainee);

  void prepareResetPassword(String id) =>
      resetPasswordParams = ResetTraineePasswordParams(id: id);
}
