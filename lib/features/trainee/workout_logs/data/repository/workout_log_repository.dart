import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';

import '../model/workout_log_model.dart';
import '../params/workout_log_params.dart';

/// HTTP boundary for the trainee's workout logs.
class WorkoutLogRepository extends CoreRepository {
  /// Create a log from a plan day (server snapshots prescribed + seeds actuals).
  Future<Result<WorkoutLogModel>> logFromDayRequest({
    required WorkoutLogFromDayParams params,
  }) async {
    final result = await RemoteDataSource.request<WorkoutLogModel>(
      withAuthentication: true,
      url: myWorkoutLogFromDayUrl,
      method: HttpMethod.POST,
      data: params.toJson(),
      converter: (json) => WorkoutLogModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<WorkoutLogModel>> getWorkoutLogByIdRequest({
    required String id,
  }) async {
    final result = await RemoteDataSource.request<WorkoutLogModel>(
      withAuthentication: true,
      url: '$myWorkoutLogUrl/$id',
      method: HttpMethod.GET,
      converter: (json) => WorkoutLogModel.fromJson(json),
    );
    return call(result: result);
  }

  /// Paged workout-log history (headers only — empty entries); fetch `/{id}`
  /// for the enriched prescribed-vs-actual detail. Optional date range + sort.
  Future<Result<List<WorkoutLogModel>>> getWorkoutLogListRequest({
    required MyWorkoutLogListInput params,
  }) async {
    final result = await RemoteDataSource.request<List<WorkoutLogModel>>(
      withAuthentication: true,
      url: myWorkoutLogUrl,
      method: HttpMethod.GET,
      queryParameters: params.toJson(),
      converter: (json) {
        final List<dynamic> data = json['items'] ?? json['data'] ?? [];
        return data
            .map((e) => WorkoutLogModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return paginatedCall(result: result);
  }

  /// Full-replace update — actual fields only (server preserves prescribed).
  Future<Result<WorkoutLogModel>> updateWorkoutLogRequest({
    required UpdateWorkoutLogParams params,
  }) async {
    final result = await RemoteDataSource.request<WorkoutLogModel>(
      withAuthentication: true,
      url: '$myWorkoutLogUrl/${params.id}',
      method: HttpMethod.PUT,
      data: params.toJson(),
      converter: (json) => WorkoutLogModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<String>> deleteWorkoutLogRequest({required String id}) async {
    final result = await RemoteDataSource.noModelRequest(
      withAuthentication: true,
      url: '$myWorkoutLogUrl/$id',
      method: HttpMethod.DELETE,
    );
    return noModelCall(result: result);
  }
}
