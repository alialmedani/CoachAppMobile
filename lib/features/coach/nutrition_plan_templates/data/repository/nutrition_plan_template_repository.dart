import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';

import '../params/clone_nutrition_template_params.dart';
import '../params/create_update_nutrition_plan_template_params.dart';
import '../params/get_nutrition_plan_template_list_input.dart';
import '../params/save_nutrition_plan_as_template_params.dart';

/// HTTP boundary for the coach nutrition-plan-template feature. Every call goes
/// through [RemoteDataSource] and returns a `Result` via the [CoreRepository]
/// helpers (`call` / `paginatedCall` / `noModelCall`).
///
/// The read/write shapes are the plan's minus `traineeId`/`isActive`, so the
/// coach [NutritionPlanModel] tree is reused for parsing (its `fromJson`
/// tolerates the missing fields). Clone and save-as-template also parse into
/// [NutritionPlanModel] (clone returns a real `NutritionPlanDto`).
class NutritionPlanTemplateRepository extends CoreRepository {
  /// Paged template summaries (meals not loaded server-side; macros zero).
  Future<Result<List<NutritionPlanModel>>>
  getNutritionPlanTemplateListRequest({
    required GetNutritionPlanTemplateListInput params,
  }) async {
    final result = await RemoteDataSource.request<List<NutritionPlanModel>>(
      withAuthentication: true,
      url: nutritionPlanTemplateUrl,
      method: HttpMethod.GET,
      queryParameters: params.toJson(),
      converter: (json) {
        final List<dynamic> data = json['items'] ?? json['data'] ?? [];
        return data.map((e) => NutritionPlanModel.fromJson(e)).toList();
      },
    );
    return paginatedCall(result: result);
  }

  /// Full template with meals and items (`foodName`/`servingUnit` enriched,
  /// macros and totals computed server-side).
  Future<Result<NutritionPlanModel>> getNutritionPlanTemplateByIdRequest({
    required String id,
  }) async {
    final result = await RemoteDataSource.request<NutritionPlanModel>(
      withAuthentication: true,
      url: '$nutritionPlanTemplateUrl/$id',
      method: HttpMethod.GET,
      converter: (json) => NutritionPlanModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<NutritionPlanModel>> createNutritionPlanTemplateRequest({
    required CreateUpdateNutritionPlanTemplateParams params,
  }) async {
    final result = await RemoteDataSource.request<NutritionPlanModel>(
      withAuthentication: true,
      url: nutritionPlanTemplateUrl,
      method: HttpMethod.POST,
      data: params.toJson(),
      converter: (json) => NutritionPlanModel.fromJson(json),
    );
    return call(result: result);
  }

  /// Full replace of the template tree (server rebuilds meals/items and
  /// recomputes the macro totals).
  Future<Result<NutritionPlanModel>> updateNutritionPlanTemplateRequest({
    required String id,
    required CreateUpdateNutritionPlanTemplateParams params,
  }) async {
    final result = await RemoteDataSource.request<NutritionPlanModel>(
      withAuthentication: true,
      url: '$nutritionPlanTemplateUrl/$id',
      method: HttpMethod.PUT,
      data: params.toJson(),
      converter: (json) => NutritionPlanModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<String>> deleteNutritionPlanTemplateRequest({
    required String id,
  }) async {
    final result = await RemoteDataSource.noModelRequest(
      withAuthentication: true,
      url: '$nutritionPlanTemplateUrl/$id',
      method: HttpMethod.DELETE,
    );
    return noModelCall(result: result);
  }

  /// Clones this template onto a trainee → a new, **inactive** real nutrition
  /// plan (`NutritionPlanDto`). Gated server-side by `NutritionPlans.Create`.
  Future<Result<NutritionPlanModel>> cloneToTraineeRequest({
    required CloneNutritionTemplateParams params,
  }) async {
    final result = await RemoteDataSource.request<NutritionPlanModel>(
      withAuthentication: true,
      url: '$nutritionPlanTemplateUrl/${params.id}/clone-to-trainee',
      method: HttpMethod.POST,
      data: params.toJson(),
      converter: (json) => NutritionPlanModel.fromJson(json),
    );
    return call(result: result);
  }

  /// Snapshots an existing trainee nutrition plan into a new template.
  Future<Result<NutritionPlanModel>> saveAsTemplateRequest({
    required SaveNutritionPlanAsTemplateParams params,
  }) async {
    final result = await RemoteDataSource.request<NutritionPlanModel>(
      withAuthentication: true,
      url: '$nutritionPlanTemplateUrl/save-as-template',
      method: HttpMethod.POST,
      data: params.toJson(),
      converter: (json) => NutritionPlanModel.fromJson(json),
    );
    return call(result: result);
  }
}
