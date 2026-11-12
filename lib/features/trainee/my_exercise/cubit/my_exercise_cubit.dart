import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/results/result.dart';

import '../data/params/get_my_exercise_params.dart';
import '../data/repository/my_exercise_repository.dart';
import '../data/usecase/get_my_exercise_usecase.dart';

part 'my_exercise_state.dart';

/// Orchestrates the trainee's read-only exercise-detail screen. The boilerplate
/// [GetModel] widget owns the Loading/Success/Error state from the returned
/// `Result`, so this cubit never calls `emit` for API state.
class MyExerciseCubit extends Cubit<MyExerciseState> {
  MyExerciseCubit() : super(MyExerciseInitial());

  final MyExerciseRepository _repository = MyExerciseRepository();

  Future<Result> fetchExerciseById(String id) =>
      GetMyExerciseUsecase(_repository).call(params: GetMyExerciseParams(id: id));
}
