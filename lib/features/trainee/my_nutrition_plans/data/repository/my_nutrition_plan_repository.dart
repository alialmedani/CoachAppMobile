import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';

/// HTTP boundary for the trainee's own nutrition plans (read-only `My*` API).
///
/// GetList returns an **unpaged top-level array** of summaries (meals empty,
/// totals 0); `/{id}` returns the full enriched tree with server-computed
/// macros/totals. Reuses the coach [NutritionPlanModel].
class MyNutritionPlanRepository extends CoreRepository {
  /// The trainee's plans as summaries (meals not loaded). Unpaged array →
  /// mapped via `converter2`.
  Future<Result<List<NutritionPlanModel>>> getMyNutritionPlansRequest() async {
    final result = await RemoteDataSource.request<List<NutritionPlanModel>>(
      withAuthentication: true,
      url: myNutritionPlanUrl,
      method: HttpMethod.GET,
      converter2: (json) => (json as List)
          .map((e) => NutritionPlanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return call(result: result);
  }

  /// Full plan tree (meals → items, food names + computed macros + totals).
  Future<Result<NutritionPlanModel>> getMyNutritionPlanByIdRequest({
    required String id,
  }) async {
    final result = await RemoteDataSource.request<NutritionPlanModel>(
      withAuthentication: true,
      url: '$myNutritionPlanUrl/$id',
      method: HttpMethod.GET,
      converter: (json) => NutritionPlanModel.fromJson(json),
    );
    return call(result: result);
  }
}
