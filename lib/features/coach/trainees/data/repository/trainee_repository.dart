import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';

import '../model/trainee_model.dart';
import '../usecase/create_trainee_usecase.dart';
import '../usecase/get_trainee_list_usecase.dart';
import '../usecase/reset_trainee_password_usecase.dart';
import '../usecase/update_trainee_usecase.dart';

class TraineeRepository extends CoreRepository {
  Future<Result<List<TraineeModel>>> getTraineeListRequest({
    required GetTraineeListParams params,
  }) async {
    final result = await RemoteDataSource.request<List<TraineeModel>>(
      withAuthentication: true,
      url: traineeUrl,
      method: HttpMethod.GET,
      queryParameters: params.toJson(),
      converter: (json) {
        final List<dynamic> data = json['items'] ?? json['data'] ?? [];
        return data.map((e) => TraineeModel.fromJson(e)).toList();
      },
    );
    return paginatedCall(result: result);
  }

  Future<Result<TraineeModel>> getTraineeByIdRequest({
    required String id,
  }) async {
    final result = await RemoteDataSource.request<TraineeModel>(
      withAuthentication: true,
      url: '$traineeUrl/$id',
      method: HttpMethod.GET,
      converter: (json) => TraineeModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<TraineeModel>> createTraineeRequest({
    required CreateTraineeParams params,
  }) async {
    final result = await RemoteDataSource.request<TraineeModel>(
      withAuthentication: true,
      url: traineeUrl,
      method: HttpMethod.POST,
      data: params.toJson(),
      converter: (json) => TraineeModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<TraineeModel>> updateTraineeRequest({
    required String id,
    required UpdateTraineeParams params,
  }) async {
    final result = await RemoteDataSource.request<TraineeModel>(
      withAuthentication: true,
      url: '$traineeUrl/$id',
      method: HttpMethod.PUT,
      data: params.toJson(),
      converter: (json) => TraineeModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<String>> deleteTraineeRequest({required String id}) async {
    final result = await RemoteDataSource.noModelRequest(
      withAuthentication: true,
      url: '$traineeUrl/$id',
      method: HttpMethod.DELETE,
    );
    return noModelCall(result: result);
  }

  Future<Result<String>> resetTraineePasswordRequest({
    required String id,
    required ResetTraineePasswordParams params,
  }) async {
    final result = await RemoteDataSource.noModelRequest(
      withAuthentication: true,
      url: '$traineeUrl/$id/reset-password',
      method: HttpMethod.POST,
      data: params.toJson(),
    );
    return noModelCall(result: result);
  }
}
