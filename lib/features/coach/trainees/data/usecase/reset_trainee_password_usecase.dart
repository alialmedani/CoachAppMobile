import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../repository/trainee_repository.dart';

/// Coach-set new password for a trainee (ABP `ResetTraineePasswordDto`).
class ResetTraineePasswordParams extends BaseParams {
  String id;
  String newPassword;

  ResetTraineePasswordParams({this.id = '', this.newPassword = ''});

  Map<String, dynamic> toJson() => {'newPassword': newPassword};
}

class ResetTraineePasswordUsecase
    extends UseCase<String, ResetTraineePasswordParams> {
  final TraineeRepository repository;

  ResetTraineePasswordUsecase(this.repository);

  @override
  Future<Result<String>> call({required ResetTraineePasswordParams params}) {
    return repository.resetTraineePasswordRequest(
      id: params.id,
      params: params,
    );
  }
}
