import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/exercise_model.dart';
import '../repository/exercise_repository.dart';

class GetExerciseParams extends BaseParams {
  final String id;

  GetExerciseParams({required this.id});

  Map<String, dynamic> toJson() => <String, dynamic>{};
}

class GetExerciseUsecase extends UseCase<ExerciseModel, GetExerciseParams> {
  final ExerciseRepository repository;

  GetExerciseUsecase(this.repository);

  @override
  Future<Result<ExerciseModel>> call({required GetExerciseParams params}) {
    return repository.getExerciseByIdRequest(id: params.id);
  }
}
