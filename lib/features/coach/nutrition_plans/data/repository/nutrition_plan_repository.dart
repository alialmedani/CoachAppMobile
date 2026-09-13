import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';

import '../model/nutrition_plan_model.dart';
import '../params/create_update_nutrition_plan_params.dart';
import '../params/get_nutrition_plan_list_input.dart';

/// HTTP boundary for the coach nutrition-plan feature. Every call goes through
/// [RemoteDataSource] and returns a `Result` via the [CoreRepository] helpers
/// (`call` / `paginatedCall` / `noModelCall`).
class NutritionPlanRepository extends CoreRepository {
  /// Paged plan summaries (meals not loaded server-side).
  Future<Result<List<NutritionPlanModel>>> getNutritionPlanListRequest({
    required GetNutritionPlanListInput params,
  }) async {
    final result = await RemoteDataSource.request<List<NutritionPlanModel>>(
      withAuthentication: true,
      url: nutritionPlanUrl,
      method: HttpMethod.GET,
      queryParameters: params.toJson(),
      converter: (json) {
        final List<dynamic> data = json['items'] ?? json['data'] ?? [];
        return data.map((e) => NutritionPlanModel.fromJson(e)).toList();
      },
    );
    return paginatedCall(result: result);
  }

  /// Full plan with meals and items (`foodName`/`servingUnit` enriched, macros
  /// and totals computed server-side).
  Future<Result<NutritionPlanModel>> getNutritionPlanByIdRequest({
    required String id,
  }) async {
    final result = await RemoteDataSource.request<NutritionPlanModel>(
      withAuthentication: true,
      url: '$nutritionPlanUrl/$id',
      method: HttpMethod.GET,
      converter: (json) => NutritionPlanModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<NutritionPlanModel>> createNutritionPlanRequest({
    required CreateUpdateNutritionPlanParams params,
  }) async {
    final result = await RemoteDataSource.request<NutritionPlanModel>(
      withAuthentication: true,
      url: nutritionPlanUrl,
      method: HttpMethod.POST,
      data: params.toJson(),
      converter: (json) => NutritionPlanModel.fromJson(json),
    );
    return call(result: result);
  }

  /// Full replace of the plan tree (server rebuilds meals/items and recomputes
  /// the macro totals).
  Future<Result<NutritionPlanModel>> updateNutritionPlanRequest({
    required String id,
    required CreateUpdateNutritionPlanParams params,
  }) async {
    final result = await RemoteDataSource.request<NutritionPlanModel>(
      withAuthentication: true,
      url: '$nutritionPlanUrl/$id',
      method: HttpMethod.PUT,
      data: params.toJson(),
      converter: (json) => NutritionPlanModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<String>> deleteNutritionPlanRequest({
    required String id,
  }) async {
    final result = await RemoteDataSource.noModelRequest(
      withAuthentication: true,
      url: '$nutritionPlanUrl/$id',
      method: HttpMethod.DELETE,
    );
    return noModelCall(result: result);
  }

  /// Makes this the trainee's active plan; the server deactivates their others.
  Future<Result<NutritionPlanModel>> setActiveNutritionPlanRequest({
    required String id,
  }) async {
    final result = await RemoteDataSource.request<NutritionPlanModel>(
      withAuthentication: true,
      url: '$nutritionPlanUrl/$id/set-active',
      method: HttpMethod.POST,
      converter: (json) => NutritionPlanModel.fromJson(json),
    );
    return call(result: result);
  }
}
