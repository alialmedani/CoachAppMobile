import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';

import '../model/nutrition_log_model.dart';
import '../params/nutrition_log_params.dart';

/// HTTP boundary for the trainee's nutrition logs.
class NutritionLogRepository extends CoreRepository {
  /// Create a log from a plan (server flattens meals → items into entries).
  Future<Result<NutritionLogModel>> logFromPlanRequest({
    required NutritionLogFromPlanParams params,
  }) async {
    final result = await RemoteDataSource.request<NutritionLogModel>(
      withAuthentication: true,
      url: myNutritionLogFromPlanUrl,
      method: HttpMethod.POST,
      data: params.toJson(),
      converter: (json) => NutritionLogModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<NutritionLogModel>> getNutritionLogByIdRequest({
    required String id,
  }) async {
    final result = await RemoteDataSource.request<NutritionLogModel>(
      withAuthentication: true,
      url: '$myNutritionLogUrl/$id',
      method: HttpMethod.GET,
      converter: (json) => NutritionLogModel.fromJson(json),
    );
    return call(result: result);
  }

  /// Paged log list for a single day (`FromDate == ToDate`), newest first —
  /// used to resolve "today's" already-existing log so it can be viewed/edited.
  Future<Result<List<NutritionLogModel>>> getNutritionLogsByDateRequest({
    required String date,
  }) async {
    final result = await RemoteDataSource.request<List<NutritionLogModel>>(
      withAuthentication: true,
      url: myNutritionLogUrl,
      method: HttpMethod.GET,
      queryParameters: {
        'SkipCount': 0,
        'MaxResultCount': 20,
        'Sorting': 'Date desc',
        'FromDate': date,
        'ToDate': date,
      },
      converter: (json) {
        final List<dynamic> data = json['items'] ?? json['data'] ?? [];
        return data
            .map((e) => NutritionLogModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return call(result: result);
  }

  /// Paged nutrition-log history (headers only — empty entries / zero totals);
  /// fetch `/{id}` for the enriched detail. Optional date range + sorting.
  Future<Result<List<NutritionLogModel>>> getNutritionLogListRequest({
    required MyNutritionLogListInput params,
  }) async {
    final result = await RemoteDataSource.request<List<NutritionLogModel>>(
      withAuthentication: true,
      url: myNutritionLogUrl,
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

  /// Full-replace update — foodId/order/quantity/notes only (macros computed).
  Future<Result<NutritionLogModel>> updateNutritionLogRequest({
    required UpdateNutritionLogParams params,
  }) async {
    final result = await RemoteDataSource.request<NutritionLogModel>(
      withAuthentication: true,
      url: '$myNutritionLogUrl/${params.id}',
      method: HttpMethod.PUT,
      data: params.toJson(),
      converter: (json) => NutritionLogModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<String>> deleteNutritionLogRequest({required String id}) async {
    final result = await RemoteDataSource.noModelRequest(
      withAuthentication: true,
      url: '$myNutritionLogUrl/$id',
      method: HttpMethod.DELETE,
    );
    return noModelCall(result: result);
  }
}
