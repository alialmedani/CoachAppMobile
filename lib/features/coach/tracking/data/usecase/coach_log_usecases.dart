import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/trainee/nutrition_logs/data/model/nutrition_log_model.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';
import 'package:coachappmobile/features/trainee/workout_logs/data/model/workout_log_model.dart';

import '../params/tracking_list_input.dart';
import '../repository/coach_log_repository.dart';

class GetCoachWorkoutLogListUsecase
    extends UseCase<List<WorkoutLogModel>, TrackingListInput> {
  final CoachLogRepository repository;

  GetCoachWorkoutLogListUsecase(this.repository);

  @override
  Future<Result<List<WorkoutLogModel>>> call({
    required TrackingListInput params,
  }) => repository.getWorkoutLogListRequest(params: params);
}

class GetCoachWorkoutLogUsecase extends UseCase<WorkoutLogModel, ByIdParams> {
  final CoachLogRepository repository;

  GetCoachWorkoutLogUsecase(this.repository);

  @override
  Future<Result<WorkoutLogModel>> call({required ByIdParams params}) =>
      repository.getWorkoutLogByIdRequest(id: params.id);
}

class GetCoachNutritionLogListUsecase
    extends UseCase<List<NutritionLogModel>, TrackingListInput> {
  final CoachLogRepository repository;

  GetCoachNutritionLogListUsecase(this.repository);

  @override
  Future<Result<List<NutritionLogModel>>> call({
    required TrackingListInput params,
  }) => repository.getNutritionLogListRequest(params: params);
}

class GetCoachNutritionLogUsecase
    extends UseCase<NutritionLogModel, ByIdParams> {
  final CoachLogRepository repository;

  GetCoachNutritionLogUsecase(this.repository);

  @override
  Future<Result<NutritionLogModel>> call({required ByIdParams params}) =>
      repository.getNutritionLogByIdRequest(id: params.id);
}
