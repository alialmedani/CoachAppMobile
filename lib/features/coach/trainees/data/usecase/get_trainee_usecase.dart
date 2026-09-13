import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/trainee_model.dart';
import '../repository/trainee_repository.dart';

/// Single trainee by id (`GET /api/app/trainee/{id}`).
class GetTraineeParams extends BaseParams {
  final String id;

  GetTraineeParams({required this.id});

  Map<String, dynamic> toJson() => <String, dynamic>{};
}

class GetTraineeUsecase extends UseCase<TraineeModel, GetTraineeParams> {
  final TraineeRepository repository;

  GetTraineeUsecase(this.repository);

  @override
  Future<Result<TraineeModel>> call({required GetTraineeParams params}) {
    return repository.getTraineeByIdRequest(id: params.id);
  }
}
