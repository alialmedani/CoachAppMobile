import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/exercise_model.dart';
import '../repository/exercise_repository.dart';
import 'create_exercise_usecase.dart';

class UpdateExerciseUsecase extends UseCase<ExerciseModel, SaveExerciseParams> {
  final ExerciseRepository repository;

  UpdateExerciseUsecase(this.repository);

  @override
  Future<Result<ExerciseModel>> call({required SaveExerciseParams params}) {
    return repository.updateExerciseRequest(id: params.id, params: params);
  }
}
