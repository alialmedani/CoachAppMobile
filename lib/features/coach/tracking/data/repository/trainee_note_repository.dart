import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';

import '../model/trainee_note_model.dart';
import '../params/trainee_note_params.dart';
import '../params/tracking_list_input.dart';

/// HTTP boundary for the coach's CRUD of a trainee's notes.
class TraineeNoteRepository extends CoreRepository {
  Future<Result<List<TraineeNoteModel>>> getListRequest({
    required TrackingListInput params,
  }) async {
    final result = await RemoteDataSource.request<List<TraineeNoteModel>>(
      withAuthentication: true,
      url: traineeNoteUrl,
      method: HttpMethod.GET,
      queryParameters: params.toJson(),
      converter: (json) {
        final List<dynamic> data = json['items'] ?? json['data'] ?? [];
        return data
            .map((e) => TraineeNoteModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return paginatedCall(result: result);
  }

  Future<Result<TraineeNoteModel>> createRequest({
    required CreateUpdateTraineeNoteParams params,
  }) async {
    final result = await RemoteDataSource.request<TraineeNoteModel>(
      withAuthentication: true,
      url: traineeNoteUrl,
      method: HttpMethod.POST,
      data: params.toJson(),
      converter: (json) => TraineeNoteModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<TraineeNoteModel>> updateRequest({
    required CreateUpdateTraineeNoteParams params,
  }) async {
    final result = await RemoteDataSource.request<TraineeNoteModel>(
      withAuthentication: true,
      url: '$traineeNoteUrl/${params.id}',
      method: HttpMethod.PUT,
      data: params.toJson(),
      converter: (json) => TraineeNoteModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<String>> deleteRequest({required String id}) async {
    final result = await RemoteDataSource.noModelRequest(
      withAuthentication: true,
      url: '$traineeNoteUrl/$id',
      method: HttpMethod.DELETE,
    );
    return noModelCall(result: result);
  }
}
