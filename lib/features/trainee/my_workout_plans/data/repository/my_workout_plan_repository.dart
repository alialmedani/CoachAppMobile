import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_plan_model.dart';

/// HTTP boundary for the trainee's own workout plans (read-only `My*` API).
///
/// GetList returns an **unpaged top-level JSON array** of summaries (days
/// empty); `/{id}` returns the full enriched tree. Both return the same
/// `WorkoutPlanDto` the coach endpoints do, so [WorkoutPlanModel] is reused.
class MyWorkoutPlanRepository extends CoreRepository {
  /// The trainee's plans as summaries (days not loaded). Unpaged: the body is
  /// a raw array, so it's mapped via `converter2` (not the `items` unwrapper).
  Future<Result<List<WorkoutPlanModel>>> getMyWorkoutPlansRequest() async {
    final result = await RemoteDataSource.request<List<WorkoutPlanModel>>(
      withAuthentication: true,
      url: myWorkoutPlanUrl,
      method: HttpMethod.GET,
      converter2: (json) => (json as List)
          .map((e) => WorkoutPlanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return call(result: result);
  }

  /// Full plan tree (days → exercises, `exerciseName` enriched). The server
  /// 404s if the plan isn't the caller's, surfaced as a `Result` error.
  Future<Result<WorkoutPlanModel>> getMyWorkoutPlanByIdRequest({
    required String id,
  }) async {
    final result = await RemoteDataSource.request<WorkoutPlanModel>(
      withAuthentication: true,
      url: '$myWorkoutPlanUrl/$id',
      method: HttpMethod.GET,
      converter: (json) => WorkoutPlanModel.fromJson(json),
    );
    return call(result: result);
  }
}
