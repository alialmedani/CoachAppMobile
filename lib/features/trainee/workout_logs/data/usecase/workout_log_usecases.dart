import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';

import '../model/workout_log_model.dart';
import '../params/workout_log_params.dart';
import '../repository/workout_log_repository.dart';

/// Create a workout log seeded from a plan day (prescribed snapshot + actuals).
class LogWorkoutFromDayUsecase
    extends UseCase<WorkoutLogModel, WorkoutLogFromDayParams> {
  final WorkoutLogRepository repository;

  LogWorkoutFromDayUsecase(this.repository);

  @override
  Future<Result<WorkoutLogModel>> call({
    required WorkoutLogFromDayParams params,
  }) => repository.logFromDayRequest(params: params);
}

class GetWorkoutLogUsecase extends UseCase<WorkoutLogModel, ByIdParams> {
  final WorkoutLogRepository repository;

  GetWorkoutLogUsecase(this.repository);

  @override
  Future<Result<WorkoutLogModel>> call({required ByIdParams params}) =>
      repository.getWorkoutLogByIdRequest(id: params.id);
}

/// Paged history of the trainee's own workout logs (newest first).
class GetMyWorkoutLogListUsecase
    extends UseCase<List<WorkoutLogModel>, MyWorkoutLogListInput> {
  final WorkoutLogRepository repository;

  GetMyWorkoutLogListUsecase(this.repository);

  @override
  Future<Result<List<WorkoutLogModel>>> call({
    required MyWorkoutLogListInput params,
  }) => repository.getWorkoutLogListRequest(params: params);
}

/// Save the trainee's actuals (full-replace; prescribed preserved server-side).
class UpdateWorkoutLogUsecase
    extends UseCase<WorkoutLogModel, UpdateWorkoutLogParams> {
  final WorkoutLogRepository repository;

  UpdateWorkoutLogUsecase(this.repository);

  @override
  Future<Result<WorkoutLogModel>> call({
    required UpdateWorkoutLogParams params,
  }) => repository.updateWorkoutLogRequest(params: params);
}

class DeleteWorkoutLogUsecase extends UseCase<String, ByIdParams> {
  final WorkoutLogRepository repository;

  DeleteWorkoutLogUsecase(this.repository);

  @override
  Future<Result<String>> call({required ByIdParams params}) =>
      repository.deleteWorkoutLogRequest(id: params.id);
}
