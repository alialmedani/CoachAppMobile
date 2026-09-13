import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';

import '../model/exercise_model.dart';
import '../usecase/create_exercise_usecase.dart';
import '../usecase/get_exercise_list_usecase.dart';

class ExerciseRepository extends CoreRepository {
  Future<Result<List<ExerciseModel>>> getExerciseListRequest({
    required GetExerciseListParams params,
  }) async {
    final result = await RemoteDataSource.request<List<ExerciseModel>>(
      withAuthentication: true,
      url: exerciseUrl,
      method: HttpMethod.GET,
      queryParameters: params.toJson(),
      converter: (json) {
        final List<dynamic> data = json['items'] ?? json['data'] ?? [];
        return data.map((e) => ExerciseModel.fromJson(e)).toList();
      },
    );
    return paginatedCall(result: result);
  }

  Future<Result<ExerciseModel>> getExerciseByIdRequest({
    required String id,
  }) async {
    final result = await RemoteDataSource.request<ExerciseModel>(
      withAuthentication: true,
      url: '$exerciseUrl/$id',
      method: HttpMethod.GET,
      converter: (json) => ExerciseModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<ExerciseModel>> createExerciseRequest({
    required SaveExerciseParams params,
  }) async {
    final result = await RemoteDataSource.request<ExerciseModel>(
      withAuthentication: true,
      url: exerciseUrl,
      method: HttpMethod.POST,
      data: params.toJson(),
      converter: (json) => ExerciseModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<ExerciseModel>> updateExerciseRequest({
    required String id,
    required SaveExerciseParams params,
  }) async {
    final result = await RemoteDataSource.request<ExerciseModel>(
      withAuthentication: true,
      url: '$exerciseUrl/$id',
      method: HttpMethod.PUT,
      data: params.toJson(),
      converter: (json) => ExerciseModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<String>> deleteExerciseRequest({required String id}) async {
    final result = await RemoteDataSource.noModelRequest(
      withAuthentication: true,
      url: '$exerciseUrl/$id',
      method: HttpMethod.DELETE,
    );
    return noModelCall(result: result);
  }
}
