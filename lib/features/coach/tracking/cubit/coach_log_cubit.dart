import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/boilerplate/pagination/models/get_list_request.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';

import '../data/params/tracking_list_input.dart';
import '../data/repository/coach_log_repository.dart';
import '../data/usecase/coach_log_usecases.dart';

part 'coach_log_state.dart';

/// Orchestrates the coach reading one trainee's workout & nutrition logs
/// (read-only). Boilerplate widgets own the async UI state.
class CoachLogCubit extends Cubit<CoachLogState> {
  CoachLogCubit() : super(CoachLogInitial());

  final CoachLogRepository _repository = CoachLogRepository();
  String _traineeId = '';

  void setTrainee(String id) => _traineeId = id;

  TrackingListInput _input() => TrackingListInput(
    request: GetListRequest(skip: 0, take: 50),
    traineeId: _traineeId,
    sorting: 'Date desc',
  );

  Future<Result> fetchWorkoutLogs() =>
      GetCoachWorkoutLogListUsecase(_repository).call(params: _input());

  Future<Result> fetchWorkoutLogById(String id) =>
      GetCoachWorkoutLogUsecase(_repository).call(params: ByIdParams(id: id));

  Future<Result> fetchNutritionLogs() =>
      GetCoachNutritionLogListUsecase(_repository).call(params: _input());

  Future<Result> fetchNutritionLogById(String id) =>
      GetCoachNutritionLogUsecase(_repository).call(params: ByIdParams(id: id));
}
