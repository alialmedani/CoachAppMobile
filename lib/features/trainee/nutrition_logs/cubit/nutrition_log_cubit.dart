import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/boilerplate/pagination/models/get_list_request.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';

import '../data/model/nutrition_log_model.dart';
import '../data/params/nutrition_log_params.dart';
import '../data/repository/nutrition_log_repository.dart';
import '../data/usecase/nutrition_log_usecases.dart';

part 'nutrition_log_state.dart';

/// Orchestrates the trainee's nutrition-log flows. Boilerplate widgets own the
/// async UI state; no `emit` for API state.
class NutritionLogCubit extends Cubit<NutritionLogState> {
  NutritionLogCubit() : super(NutritionLogInitial());

  final NutritionLogRepository _repository = NutritionLogRepository();

  // ---- history list date-range filter (plain state; no emit) ----------------
  String? historyFromDate;
  String? historyToDate;

  void setHistoryFrom(String? value) => historyFromDate = value;

  void setHistoryTo(String? value) => historyToDate = value;

  /// Paged history list — the boilerplate [PaginationList] passes a
  /// [GetListRequest] (skip/take) as [data]; merged with the current date range.
  Future<Result> fetchNutritionLogList(dynamic data) =>
      GetMyNutritionLogListUsecase(_repository).call(
        params: MyNutritionLogListInput(
          request: data as GetListRequest,
          fromDate: historyFromDate,
          toDate: historyToDate,
          sorting: 'Date desc',
        ),
      );

  Future<Result> logFromPlan({
    required String nutritionPlanId,
    required String date,
  }) => LogNutritionFromPlanUsecase(_repository).call(
    params: NutritionLogFromPlanParams(
      nutritionPlanId: nutritionPlanId,
      date: date,
    ),
  );

  /// Save-time create for the from-plan flow: POST from-plan to create the log,
  /// then PUT the trainee's edited quantities. Both calls happen ONLY on Save,
  /// so dismissing the editor persists nothing (no phantom log). Returns the
  /// create failure early; otherwise the update [Result].
  Future<Result> logFromPlanThenUpdate({
    required String nutritionPlanId,
    required String date,
    required List<NutritionLogEntryModel> entries,
    String? notes,
  }) async {
    final created = await logFromPlan(
      nutritionPlanId: nutritionPlanId,
      date: date,
    );
    if (!created.hasDataOnly) return created;
    final createdLog = created.data as NutritionLogModel;
    return updateLog(
      UpdateNutritionLogParams(
        id: createdLog.id ?? '',
        date: date,
        notes: notes,
        entries: entries,
      ),
    );
  }

  Future<Result> fetchLog(String id) =>
      GetNutritionLogUsecase(_repository).call(params: ByIdParams(id: id));

  Future<Result> fetchLogsByDate(String date) =>
      GetNutritionLogsByDateUsecase(_repository)
          .call(params: ByDateParams(date: date));

  Future<Result> updateLog(UpdateNutritionLogParams params) =>
      UpdateNutritionLogUsecase(_repository).call(params: params);

  Future<Result> deleteLog(String id) =>
      DeleteNutritionLogUsecase(_repository).call(params: ByIdParams(id: id));
}
