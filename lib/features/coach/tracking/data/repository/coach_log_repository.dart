import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/trainee/nutrition_logs/data/model/nutrition_log_model.dart';
import 'package:coachappmobile/features/trainee/workout_logs/data/model/workout_log_model.dart';

import '../params/tracking_list_input.dart';

/// HTTP boundary for the coach reading a trainee's logs (read-only). Reuses the
/// trainee log models (identical DTOs). NOTE: list rows are **headers only**
/// (empty entries / zero totals) — fetch `/{id}` for the enriched detail.
class CoachLogRepository extends CoreRepository {
  Future<Result<List<WorkoutLogModel>>> getWorkoutLogListRequest({
    required TrackingListInput params,
  }) async {
    final result = await RemoteDataSource.request<List<WorkoutLogModel>>(
      withAuthentication: true,
      url: coachWorkoutLogUrl,
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

  Future<Result<WorkoutLogModel>> getWorkoutLogByIdRequest({
    required String id,
  }) async {
    final result = await RemoteDataSource.request<WorkoutLogModel>(
      withAuthentication: true,
      url: '$coachWorkoutLogUrl/$id',
      method: HttpMethod.GET,
      converter: (json) => WorkoutLogModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<List<NutritionLogModel>>> getNutritionLogListRequest({
    required TrackingListInput params,
  }) async {
    final result = await RemoteDataSource.request<List<NutritionLogModel>>(
      withAuthentication: true,
      url: coachNutritionLogUrl,
      method: HttpMethod.GET,
      queryParameters: params.toJson(),
      converter: (json) {
        final List<dynamic> data = json['items'] ?? json['data'] ?? [];
        return data
            .map((e) => NutritionLogModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return paginatedCall(result: result);
  }

  Future<Result<NutritionLogModel>> getNutritionLogByIdRequest({
    required String id,
  }) async {
    final result = await RemoteDataSource.request<NutritionLogModel>(
      withAuthentication: true,
      url: '$coachNutritionLogUrl/$id',
      method: HttpMethod.GET,
      converter: (json) => NutritionLogModel.fromJson(json),
    );
    return call(result: result);
  }
}
