import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';

import '../model/progress_entry_model.dart';
import '../params/progress_entry_params.dart';
import '../params/tracking_list_input.dart';

/// HTTP boundary for the coach's CRUD of a trainee's progress entries.
class ProgressEntryRepository extends CoreRepository {
  Future<Result<List<ProgressEntryModel>>> getListRequest({
    required TrackingListInput params,
  }) async {
    final result = await RemoteDataSource.request<List<ProgressEntryModel>>(
      withAuthentication: true,
      url: progressEntryUrl,
      method: HttpMethod.GET,
      queryParameters: params.toJson(),
      converter: (json) {
        final List<dynamic> data = json['items'] ?? json['data'] ?? [];
        return data
            .map((e) => ProgressEntryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return paginatedCall(result: result);
  }

  Future<Result<ProgressEntryModel>> createRequest({
    required CreateUpdateProgressEntryParams params,
  }) async {
    final result = await RemoteDataSource.request<ProgressEntryModel>(
      withAuthentication: true,
      url: progressEntryUrl,
      method: HttpMethod.POST,
      data: params.toJson(),
      converter: (json) => ProgressEntryModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<ProgressEntryModel>> updateRequest({
    required CreateUpdateProgressEntryParams params,
  }) async {
    final result = await RemoteDataSource.request<ProgressEntryModel>(
      withAuthentication: true,
      url: '$progressEntryUrl/${params.id}',
      method: HttpMethod.PUT,
      data: params.toJson(),
      converter: (json) => ProgressEntryModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<String>> deleteRequest({required String id}) async {
    final result = await RemoteDataSource.noModelRequest(
      withAuthentication: true,
      url: '$progressEntryUrl/$id',
      method: HttpMethod.DELETE,
    );
    return noModelCall(result: result);
  }
}
