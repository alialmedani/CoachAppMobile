import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/token_model.dart';
import '../params/refresh_token_params.dart';
import '../repository/auth_repository.dart';

class RefreshTokenUsecase extends UseCase<TokenModel, RefreshTokenParams> {
  final AuthRepository repository;

  RefreshTokenUsecase(this.repository);

  @override
  Future<Result<TokenModel>> call({required RefreshTokenParams params}) {
    return repository.refreshRequest(params: params);
  }
}
