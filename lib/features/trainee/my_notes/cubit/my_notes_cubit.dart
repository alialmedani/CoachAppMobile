import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';

import '../data/repository/my_notes_repository.dart';
import '../data/usecase/my_notes_usecase.dart';

part 'my_notes_state.dart';

/// Orchestrates the trainee reading their coach's notes (read-only).
class MyNotesCubit extends Cubit<MyNotesState> {
  MyNotesCubit() : super(MyNotesInitial());

  final MyNotesRepository _repository = MyNotesRepository();

  Future<Result> fetchRecent() =>
      GetMyNotesUsecase(_repository).call(params: NoParams());
}
