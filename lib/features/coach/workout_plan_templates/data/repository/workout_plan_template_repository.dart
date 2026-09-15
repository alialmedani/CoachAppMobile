import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_plan_model.dart';

import '../params/clone_workout_template_params.dart';
import '../params/create_update_workout_plan_template_params.dart';
import '../params/get_workout_plan_template_list_input.dart';
import '../params/save_workout_plan_as_template_params.dart';

/// HTTP boundary for the coach workout-plan-template feature. Every call goes
/// through [RemoteDataSource] and returns a `Result` via the [CoreRepository]
/// helpers (`call` / `paginatedCall` / `noModelCall`).
///
/// The read/write shapes are the plan's minus `traineeId`/`isActive`, so the
/// coach [WorkoutPlanModel] tree is reused for parsing (its `fromJson` tolerates
/// the missing fields). Clone and save-as-template also parse into
/// [WorkoutPlanModel] (clone returns a real `WorkoutPlanDto`).
class WorkoutPlanTemplateRepository extends CoreRepository {
  /// Paged template summaries (days not loaded server-side).
  Future<Result<List<WorkoutPlanModel>>> getWorkoutPlanTemplateListRequest({
    required GetWorkoutPlanTemplateListInput params,
  }) async {
    final result = await RemoteDataSource.request<List<WorkoutPlanModel>>(
      withAuthentication: true,
      url: workoutPlanTemplateUrl,
      method: HttpMethod.GET,
      queryParameters: params.toJson(),
      converter: (json) {
        final List<dynamic> data = json['items'] ?? json['data'] ?? [];
        return data.map((e) => WorkoutPlanModel.fromJson(e)).toList();
      },
    );
    return paginatedCall(result: result);
  }

  /// Full template with days and exercises (`exerciseName` enriched).
  Future<Result<WorkoutPlanModel>> getWorkoutPlanTemplateByIdRequest({
    required String id,
  }) async {
    final result = await RemoteDataSource.request<WorkoutPlanModel>(
      withAuthentication: true,
      url: '$workoutPlanTemplateUrl/$id',
      method: HttpMethod.GET,
      converter: (json) => WorkoutPlanModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<WorkoutPlanModel>> createWorkoutPlanTemplateRequest({
    required CreateUpdateWorkoutPlanTemplateParams params,
  }) async {
    final result = await RemoteDataSource.request<WorkoutPlanModel>(
      withAuthentication: true,
      url: workoutPlanTemplateUrl,
      method: HttpMethod.POST,
      data: params.toJson(),
      converter: (json) => WorkoutPlanModel.fromJson(json),
    );
    return call(result: result);
  }

  /// Full replace of the template tree (server rebuilds days/exercises).
  Future<Result<WorkoutPlanModel>> updateWorkoutPlanTemplateRequest({
    required String id,
    required CreateUpdateWorkoutPlanTemplateParams params,
  }) async {
    final result = await RemoteDataSource.request<WorkoutPlanModel>(
      withAuthentication: true,
      url: '$workoutPlanTemplateUrl/$id',
      method: HttpMethod.PUT,
      data: params.toJson(),
      converter: (json) => WorkoutPlanModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<String>> deleteWorkoutPlanTemplateRequest({
    required String id,
  }) async {
    final result = await RemoteDataSource.noModelRequest(
      withAuthentication: true,
      url: '$workoutPlanTemplateUrl/$id',
      method: HttpMethod.DELETE,
    );
    return noModelCall(result: result);
  }

  /// Clones this template onto a trainee → a new, **inactive** real workout plan
  /// (`WorkoutPlanDto`). Gated server-side by `WorkoutPlans.Create`.
  Future<Result<WorkoutPlanModel>> cloneToTraineeRequest({
    required CloneWorkoutTemplateParams params,
  }) async {
    final result = await RemoteDataSource.request<WorkoutPlanModel>(
      withAuthentication: true,
      url: '$workoutPlanTemplateUrl/${params.id}/clone-to-trainee',
      method: HttpMethod.POST,
      data: params.toJson(),
      converter: (json) => WorkoutPlanModel.fromJson(json),
    );
    return call(result: result);
  }

  /// Snapshots an existing trainee workout plan into a new template.
  Future<Result<WorkoutPlanModel>> saveAsTemplateRequest({
    required SaveWorkoutPlanAsTemplateParams params,
  }) async {
    final result = await RemoteDataSource.request<WorkoutPlanModel>(
      withAuthentication: true,
      url: '$workoutPlanTemplateUrl/save-as-template',
      method: HttpMethod.POST,
      data: params.toJson(),
      converter: (json) => WorkoutPlanModel.fromJson(json),
    );
    return call(result: result);
  }
}
