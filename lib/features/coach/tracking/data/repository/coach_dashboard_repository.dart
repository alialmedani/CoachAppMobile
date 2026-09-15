import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';

import '../model/trainee_dashboard_model.dart';

/// HTTP boundary for the coach dashboard analytics (read-only).
class CoachDashboardRepository extends CoreRepository {
  /// Composed summary for [traineeId]: nutrition adherence for [date] and
  /// workout completion over [fromDate]..[toDate] (all ISO-8601 dates).
  Future<Result<TraineeDashboardModel>> getSummaryRequest({
    required String traineeId,
    required String date,
    required String fromDate,
    required String toDate,
  }) async {
    final result = await RemoteDataSource.request<TraineeDashboardModel>(
      withAuthentication: true,
      url: traineeDashboardSummaryUrl,
      method: HttpMethod.GET,
      queryParameters: {
        'TraineeId': traineeId,
        'Date': date,
        'FromDate': fromDate,
        'ToDate': toDate,
      },
      converter: (json) => TraineeDashboardModel.fromJson(json),
    );
    return call(result: result);
  }
}
