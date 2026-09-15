import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/coach/trainees/data/model/trainee_model.dart';

import '../params/update_my_profile_params.dart';

/// HTTP boundary for the trainee's OWN profile. Reuses the coach [TraineeModel]
/// (the `my-profile` endpoint returns the same `TraineeDto`). The trainee may
/// read it and self-edit only their contact details (phone/email/birth date).
class MyProfileRepository extends CoreRepository {
  Future<Result<TraineeModel>> getProfileRequest() async {
    final result = await RemoteDataSource.request<TraineeModel>(
      withAuthentication: true,
      url: myProfileUrl,
      method: HttpMethod.GET,
      converter: (json) => TraineeModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<TraineeModel>> updateProfileRequest({
    required UpdateMyProfileParams params,
  }) async {
    final result = await RemoteDataSource.request<TraineeModel>(
      withAuthentication: true,
      url: myProfileUrl,
      method: HttpMethod.PUT,
      data: params.toJson(),
      converter: (json) => TraineeModel.fromJson(json),
    );
    return call(result: result);
  }
}
