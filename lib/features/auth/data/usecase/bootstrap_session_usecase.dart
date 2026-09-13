import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/session_model.dart';
import '../params/bootstrap_session_params.dart';
import '../repository/auth_repository.dart';

class BootstrapSessionUsecase
    extends UseCase<SessionModel, BootstrapSessionParams> {
  final AuthRepository repository;

  BootstrapSessionUsecase(this.repository);

  @override
  Future<Result<SessionModel>> call({
    required BootstrapSessionParams params,
  }) {
    return repository.bootstrapRequest(params: params);
  }
}
