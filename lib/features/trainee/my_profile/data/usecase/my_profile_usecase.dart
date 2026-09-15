import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/coach/trainees/data/model/trainee_model.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';

import '../params/update_my_profile_params.dart';
import '../repository/my_profile_repository.dart';

class GetMyProfileUsecase extends UseCase<TraineeModel, NoParams> {
  final MyProfileRepository repository;

  GetMyProfileUsecase(this.repository);

  @override
  Future<Result<TraineeModel>> call({required NoParams params}) =>
      repository.getProfileRequest();
}

class UpdateMyProfileUsecase
    extends UseCase<TraineeModel, UpdateMyProfileParams> {
  final MyProfileRepository repository;

  UpdateMyProfileUsecase(this.repository);

  @override
  Future<Result<TraineeModel>> call({required UpdateMyProfileParams params}) =>
      repository.updateProfileRequest(params: params);
}
