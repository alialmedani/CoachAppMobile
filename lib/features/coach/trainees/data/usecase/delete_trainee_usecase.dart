import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../repository/trainee_repository.dart';

class DeleteTraineeParams extends BaseParams {
  final String id;

  DeleteTraineeParams({required this.id});

  Map<String, dynamic> toJson() => <String, dynamic>{};
}

/// Soft-delete a trainee (`DELETE /api/app/trainee/{id}`, no response body).
class DeleteTraineeUsecase extends UseCase<String, DeleteTraineeParams> {
  final TraineeRepository repository;

  DeleteTraineeUsecase(this.repository);

  @override
  Future<Result<String>> call({required DeleteTraineeParams params}) {
    return repository.deleteTraineeRequest(id: params.id);
  }
}
