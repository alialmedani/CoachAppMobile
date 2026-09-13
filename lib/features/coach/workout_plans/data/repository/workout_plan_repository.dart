import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';

import '../model/workout_plan_model.dart';
import '../params/create_update_workout_plan_params.dart';
import '../params/get_workout_plan_list_input.dart';

/// HTTP boundary for the coach workout-plan feature. Every call goes through
/// [RemoteDataSource] and returns a `Result` via the [CoreRepository] helpers
/// (`call` / `paginatedCall` / `noModelCall`).
class WorkoutPlanRepository extends CoreRepository {
  /// Paged plan summaries (days not loaded server-side).
  Future<Result<List<WorkoutPlanModel>>> getWorkoutPlanListRequest({
    required GetWorkoutPlanListInput params,
  }) async {
    final result = await RemoteDataSource.request<List<WorkoutPlanModel>>(
      withAuthentication: true,
      url: workoutPlanUrl,
      method: HttpMethod.GET,
      queryParameters: params.toJson(),
      converter: (json) {
        final List<dynamic> data = json['items'] ?? json['data'] ?? [];
        return data.map((e) => WorkoutPlanModel.fromJson(e)).toList();
      },
    );
    return paginatedCall(result: result);
  }

  /// Full plan with days and exercises (`exerciseName` enriched).
  Future<Result<WorkoutPlanModel>> getWorkoutPlanByIdRequest({
    required String id,
  }) async {
    final result = await RemoteDataSource.request<WorkoutPlanModel>(
      withAuthentication: true,
      url: '$workoutPlanUrl/$id',
      method: HttpMethod.GET,
      converter: (json) => WorkoutPlanModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<WorkoutPlanModel>> createWorkoutPlanRequest({
    required CreateUpdateWorkoutPlanParams params,
  }) async {
    final result = await RemoteDataSource.request<WorkoutPlanModel>(
      withAuthentication: true,
      url: workoutPlanUrl,
      method: HttpMethod.POST,
      data: params.toJson(),
      converter: (json) => WorkoutPlanModel.fromJson(json),
    );
    return call(result: result);
  }

  /// Full replace of the plan tree (server rebuilds days/exercises).
  Future<Result<WorkoutPlanModel>> updateWorkoutPlanRequest({
    required String id,
    required CreateUpdateWorkoutPlanParams params,
  }) async {
    final result = await RemoteDataSource.request<WorkoutPlanModel>(
      withAuthentication: true,
      url: '$workoutPlanUrl/$id',
      method: HttpMethod.PUT,
      data: params.toJson(),
      converter: (json) => WorkoutPlanModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<String>> deleteWorkoutPlanRequest({required String id}) async {
    final result = await RemoteDataSource.noModelRequest(
      withAuthentication: true,
      url: '$workoutPlanUrl/$id',
      method: HttpMethod.DELETE,
    );
    return noModelCall(result: result);
  }

  /// Makes this the trainee's active plan; the server deactivates their others.
  Future<Result<WorkoutPlanModel>> setActiveWorkoutPlanRequest({
    required String id,
  }) async {
    final result = await RemoteDataSource.request<WorkoutPlanModel>(
      withAuthentication: true,
      url: '$workoutPlanUrl/$id/set-active',
      method: HttpMethod.POST,
      converter: (json) => WorkoutPlanModel.fromJson(json),
    );
    return call(result: result);
  }
}
