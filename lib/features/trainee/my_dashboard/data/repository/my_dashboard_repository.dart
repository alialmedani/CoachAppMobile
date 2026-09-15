import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/coach/tracking/data/model/trainee_dashboard_model.dart';

/// HTTP boundary for the trainee's OWN dashboard (read-only). No `TraineeId` —
/// derived from the caller. Returns the same `TraineeDashboardDto` as the coach.
class MyDashboardRepository extends CoreRepository {
  Future<Result<TraineeDashboardModel>> getSummaryRequest({
    required String date,
    required String fromDate,
    required String toDate,
  }) async {
    final result = await RemoteDataSource.request<TraineeDashboardModel>(
      withAuthentication: true,
      url: myDashboardSummaryUrl,
      method: HttpMethod.GET,
      queryParameters: {'Date': date, 'FromDate': fromDate, 'ToDate': toDate},
      converter: (json) => TraineeDashboardModel.fromJson(json),
    );
    return call(result: result);
  }
}
