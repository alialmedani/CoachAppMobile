import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';

import '../model/my_today_model.dart';

/// HTTP boundary for the trainee's "Today" view.
class MyTodayRepository extends CoreRepository {
  /// Fetch Today for [localDate] (ISO `yyyy-MM-dd`). The date must be the
  /// trainee's **local** date so "today" respects their timezone; the server
  /// resolves the weekday and scheduled day from it.
  Future<Result<MyTodayModel>> getMyTodayRequest({
    required String localDate,
  }) async {
    final result = await RemoteDataSource.request<MyTodayModel>(
      withAuthentication: true,
      url: myTodayUrl,
      method: HttpMethod.GET,
      queryParameters: {'Date': localDate},
      converter: (json) => MyTodayModel.fromJson(json),
    );
    return call(result: result);
  }
}
