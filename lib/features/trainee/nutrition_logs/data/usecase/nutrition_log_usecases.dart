import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';

import '../model/nutrition_log_model.dart';
import '../params/nutrition_log_params.dart';
import '../repository/nutrition_log_repository.dart';

/// Create a nutrition log seeded from a plan (meals → items flattened).
class LogNutritionFromPlanUsecase
    extends UseCase<NutritionLogModel, NutritionLogFromPlanParams> {
  final NutritionLogRepository repository;

  LogNutritionFromPlanUsecase(this.repository);

  @override
  Future<Result<NutritionLogModel>> call({
    required NutritionLogFromPlanParams params,
  }) => repository.logFromPlanRequest(params: params);
}

class GetNutritionLogUsecase extends UseCase<NutritionLogModel, ByIdParams> {
  final NutritionLogRepository repository;

  GetNutritionLogUsecase(this.repository);

  @override
  Future<Result<NutritionLogModel>> call({required ByIdParams params}) =>
      repository.getNutritionLogByIdRequest(id: params.id);
}

/// Resolve the trainee's log(s) for a single day (newest first).
class GetNutritionLogsByDateUsecase
    extends UseCase<List<NutritionLogModel>, ByDateParams> {
  final NutritionLogRepository repository;

  GetNutritionLogsByDateUsecase(this.repository);

  @override
  Future<Result<List<NutritionLogModel>>> call({
    required ByDateParams params,
  }) => repository.getNutritionLogsByDateRequest(date: params.date);
}

/// Paged history of the trainee's own nutrition logs (newest first).
class GetMyNutritionLogListUsecase
    extends UseCase<List<NutritionLogModel>, MyNutritionLogListInput> {
  final NutritionLogRepository repository;

  GetMyNutritionLogListUsecase(this.repository);

  @override
  Future<Result<List<NutritionLogModel>>> call({
    required MyNutritionLogListInput params,
  }) => repository.getNutritionLogListRequest(params: params);
}

class UpdateNutritionLogUsecase
    extends UseCase<NutritionLogModel, UpdateNutritionLogParams> {
  final NutritionLogRepository repository;

  UpdateNutritionLogUsecase(this.repository);

  @override
  Future<Result<NutritionLogModel>> call({
    required UpdateNutritionLogParams params,
  }) => repository.updateNutritionLogRequest(params: params);
}

class DeleteNutritionLogUsecase extends UseCase<String, ByIdParams> {
  final NutritionLogRepository repository;

  DeleteNutritionLogUsecase(this.repository);

  @override
  Future<Result<String>> call({required ByIdParams params}) =>
      repository.deleteNutritionLogRequest(id: params.id);
}
