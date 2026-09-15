import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/coach/tracking/data/model/progress_entry_model.dart';

import '../params/create_my_progress_params.dart';
// UpdateMyProgressParams also lives in create_my_progress_params.dart.

/// HTTP boundary for the trainee's OWN progress (create / list / update /
/// delete). Reuses the shared [ProgressEntryModel]. Update/delete only succeed
/// on entries the trainee authored — the backend guards coach-authored ones.
class MyProgressRepository extends CoreRepository {
  /// Recent entries (newest first) — enough for the trend chart + list.
  Future<Result<List<ProgressEntryModel>>> getRecentRequest() async {
    final result = await RemoteDataSource.request<List<ProgressEntryModel>>(
      withAuthentication: true,
      url: myProgressUrl,
      method: HttpMethod.GET,
      queryParameters: {
        'SkipCount': 0,
        'MaxResultCount': 100,
        'Sorting': 'Date desc',
      },
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
    required CreateMyProgressParams params,
  }) async {
    final result = await RemoteDataSource.request<ProgressEntryModel>(
      withAuthentication: true,
      url: myProgressUrl,
      method: HttpMethod.POST,
      data: params.toJson(),
      converter: (json) => ProgressEntryModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<ProgressEntryModel>> updateRequest({
    required UpdateMyProgressParams params,
  }) async {
    final result = await RemoteDataSource.request<ProgressEntryModel>(
      withAuthentication: true,
      url: '$myProgressUrl/${params.id}',
      method: HttpMethod.PUT,
      data: params.toJson(),
      converter: (json) => ProgressEntryModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<String>> deleteRequest({required String id}) async {
    final result = await RemoteDataSource.noModelRequest(
      withAuthentication: true,
      url: '$myProgressUrl/$id',
      method: HttpMethod.DELETE,
    );
    return noModelCall(result: result);
  }
}
