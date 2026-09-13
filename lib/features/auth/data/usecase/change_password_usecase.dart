import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../params/change_password_params.dart';
import '../repository/auth_repository.dart';

class ChangePasswordUsecase extends UseCase<String, ChangePasswordParams> {
  final AuthRepository repository;

  ChangePasswordUsecase(this.repository);

  @override
  Future<Result<String>> call({required ChangePasswordParams params}) {
    return repository.changePasswordRequest(params: params);
  }
}
