import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:meta/meta.dart';

import '../data/model/exercise_model.dart';
import '../data/repository/exercise_repository.dart';
import '../data/usecase/create_exercise_usecase.dart';
import '../data/usecase/delete_exercise_usecase.dart';
import '../data/usecase/get_exercise_list_usecase.dart';
import '../data/usecase/get_exercise_usecase.dart';
import '../data/usecase/update_exercise_usecase.dart';

part 'exercise_state.dart';

/// Orchestrates the coach exercise library. API methods return `Future<Result>`
/// (boilerplate-driven); only search/filter setters emit.
class ExerciseCubit extends Cubit<ExerciseState> {
  ExerciseCubit() : super(ExerciseInitial());

  final ExerciseRepository _repository = ExerciseRepository();

  SaveExerciseParams saveParams = SaveExerciseParams();

  String searchTerm = '';
  int? filterMuscle;
  int? filterEquipment;

  void setSearchTerm(String value) {
    searchTerm = value;
    emit(ExerciseSearchChanged());
  }

  void setFilterMuscle(int? value) {
    filterMuscle = value;
    emit(ExerciseSearchChanged());
  }

  void setFilterEquipment(int? value) {
    filterEquipment = value;
    emit(ExerciseSearchChanged());
  }

  Future<Result> fetchExerciseList(dynamic data) async {
    return await GetExerciseListUsecase(_repository).call(
      params: GetExerciseListParams(
        request: data,
        filter: searchTerm.isNotEmpty ? searchTerm : null,
        targetMuscle: filterMuscle,
        equipment: filterEquipment,
      ),
    );
  }

  Future<Result> fetchExerciseById(String id) async {
    return await GetExerciseUsecase(_repository).call(
      params: GetExerciseParams(id: id),
    );
  }

  Future<Result> createExercise() async {
    return await CreateExerciseUsecase(_repository).call(params: saveParams);
  }

  Future<Result> updateExercise() async {
    return await UpdateExerciseUsecase(_repository).call(params: saveParams);
  }

  Future<Result> deleteExercise(String id) async {
    return await DeleteExerciseUsecase(_repository).call(
      params: DeleteExerciseParams(id: id),
    );
  }

  void prepareCreate() => saveParams = SaveExerciseParams();

  void prepareEdit(ExerciseModel exercise) =>
      saveParams = SaveExerciseParams.fromModel(exercise);
}
