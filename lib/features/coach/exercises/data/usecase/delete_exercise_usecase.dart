import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../repository/exercise_repository.dart';

class DeleteExerciseParams extends BaseParams {
  final String id;

  DeleteExerciseParams({required this.id});

  Map<String, dynamic> toJson() => <String, dynamic>{};
}

class DeleteExerciseUsecase extends UseCase<String, DeleteExerciseParams> {
  final ExerciseRepository repository;

  DeleteExerciseUsecase(this.repository);

  @override
  Future<Result<String>> call({required DeleteExerciseParams params}) {
    return repository.deleteExerciseRequest(id: params.id);
  }
}
