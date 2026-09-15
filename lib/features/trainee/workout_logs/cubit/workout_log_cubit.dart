import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/boilerplate/pagination/models/get_list_request.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';

import '../data/model/workout_log_model.dart';
import '../data/params/workout_log_params.dart';
import '../data/repository/workout_log_repository.dart';
import '../data/usecase/workout_log_usecases.dart';

part 'workout_log_state.dart';

/// Orchestrates the trainee's workout-log flows. Boilerplate widgets own the
/// async UI state from the returned `Result`; no `emit` for API state.
class WorkoutLogCubit extends Cubit<WorkoutLogState> {
  WorkoutLogCubit() : super(WorkoutLogInitial());

  final WorkoutLogRepository _repository = WorkoutLogRepository();

  // ---- history list date-range filter (plain state; no emit) ----------------
  String? historyFromDate;
  String? historyToDate;

  void setHistoryFrom(String? value) => historyFromDate = value;

  void setHistoryTo(String? value) => historyToDate = value;

  /// Paged history list — the boilerplate [PaginationList] passes a
  /// [GetListRequest] (skip/take) as [data]; merged with the current date range.
  Future<Result> fetchWorkoutLogList(dynamic data) =>
      GetMyWorkoutLogListUsecase(_repository).call(
        params: MyWorkoutLogListInput(
          request: data as GetListRequest,
          fromDate: historyFromDate,
          toDate: historyToDate,
          sorting: 'Date desc',
        ),
      );

  Future<Result> logFromDay({
    required String workoutDayId,
    required String date,
  }) => LogWorkoutFromDayUsecase(_repository).call(
    params: WorkoutLogFromDayParams(workoutDayId: workoutDayId, date: date),
  );

  /// Save-time create for the from-day flow: POST from-day to create the log,
  /// then PUT the trainee's edited actuals. Both calls happen ONLY on Save, so
  /// dismissing the editor persists nothing (no phantom "completed" log).
  /// Returns the create failure early; otherwise the update [Result].
  Future<Result> logFromDayThenUpdate({
    required String workoutDayId,
    required String date,
    required List<WorkoutLogEntryModel> entries,
    String? notes,
  }) async {
    final created = await logFromDay(workoutDayId: workoutDayId, date: date);
    if (!created.hasDataOnly) return created;
    final createdLog = created.data as WorkoutLogModel;
    return updateLog(
      UpdateWorkoutLogParams(
        id: createdLog.id ?? '',
        date: date,
        notes: notes,
        entries: entries,
      ),
    );
  }

  Future<Result> fetchLog(String id) =>
      GetWorkoutLogUsecase(_repository).call(params: ByIdParams(id: id));

  Future<Result> updateLog(UpdateWorkoutLogParams params) =>
      UpdateWorkoutLogUsecase(_repository).call(params: params);

  Future<Result> deleteLog(String id) =>
      DeleteWorkoutLogUsecase(_repository).call(params: ByIdParams(id: id));
}
