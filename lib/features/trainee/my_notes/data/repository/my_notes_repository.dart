import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/coach/tracking/data/model/trainee_note_model.dart';

/// HTTP boundary for the trainee reading their coach's notes (read-only). The
/// list carries the full `text`, so no separate detail fetch is needed.
class MyNotesRepository extends CoreRepository {
  Future<Result<List<TraineeNoteModel>>> getRecentRequest() async {
    final result = await RemoteDataSource.request<List<TraineeNoteModel>>(
      withAuthentication: true,
      url: myNoteUrl,
      method: HttpMethod.GET,
      queryParameters: {
        'SkipCount': 0,
        'MaxResultCount': 100,
        'Sorting': 'Date desc',
      },
      converter: (json) {
        final List<dynamic> data = json['items'] ?? json['data'] ?? [];
        return data
            .map((e) => TraineeNoteModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return paginatedCall(result: result);
  }
}
