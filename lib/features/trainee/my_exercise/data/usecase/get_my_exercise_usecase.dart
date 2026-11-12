import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/coach/exercises/data/model/exercise_model.dart';

import '../params/get_my_exercise_params.dart';
import '../repository/my_exercise_repository.dart';

/// Fetch the details of one exercise the trainee can see, by id.
class GetMyExerciseUsecase extends UseCase<ExerciseModel, GetMyExerciseParams> {
  final MyExerciseRepository repository;

  GetMyExerciseUsecase(this.repository);

  @override
  Future<Result<ExerciseModel>> call({required GetMyExerciseParams params}) {
    return repository.getExerciseRequest(params.id);
  }
}
