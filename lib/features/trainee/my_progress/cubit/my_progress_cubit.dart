import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';

import '../data/params/create_my_progress_params.dart';
import '../data/repository/my_progress_repository.dart';
import '../data/usecase/my_progress_usecases.dart';

part 'my_progress_state.dart';

/// Orchestrates the trainee's own progress (create / list / update / delete).
/// Update & delete succeed only on trainee-authored entries; the backend guards
/// coach-authored ones and returns a localized business error.
class MyProgressCubit extends Cubit<MyProgressState> {
  MyProgressCubit() : super(MyProgressInitial());

  final MyProgressRepository _repository = MyProgressRepository();

  Future<Result> fetchRecent() =>
      GetMyProgressListUsecase(_repository).call(params: NoParams());

  Future<Result> createEntry(CreateMyProgressParams params) =>
      CreateMyProgressUsecase(_repository).call(params: params);

  Future<Result> updateEntry(UpdateMyProgressParams params) =>
      UpdateMyProgressUsecase(_repository).call(params: params);

  Future<Result> deleteEntry(String id) =>
      DeleteMyProgressUsecase(_repository).call(params: ByIdParams(id: id));
}
