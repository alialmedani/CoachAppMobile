import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/token_model.dart';
import '../params/login_params.dart';
import '../repository/auth_repository.dart';

class LoginUsecase extends UseCase<TokenModel, LoginParams> {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  @override
  Future<Result<TokenModel>> call({required LoginParams params}) {
    return repository.loginRequest(params: params);
  }
}
