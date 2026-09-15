import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/boilerplate/pagination/models/get_list_request.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';

import '../data/params/trainee_note_params.dart';
import '../data/params/tracking_list_input.dart';
import '../data/repository/trainee_note_repository.dart';
import '../data/usecase/note_usecases.dart';

part 'notes_state.dart';

/// Orchestrates the coach's CRUD of one trainee's notes.
class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(NotesInitial());

  final TraineeNoteRepository _repository = TraineeNoteRepository();
  String _traineeId = '';

  String get traineeId => _traineeId;
  void setTrainee(String id) => _traineeId = id;

  Future<Result> fetchRecent() => GetNoteListUsecase(_repository).call(
    params: TrackingListInput(
      request: GetListRequest(skip: 0, take: 100),
      traineeId: _traineeId,
      sorting: 'Date desc',
    ),
  );

  Future<Result> createNote(CreateUpdateTraineeNoteParams params) =>
      CreateNoteUsecase(_repository).call(params: params);

  Future<Result> updateNote(CreateUpdateTraineeNoteParams params) =>
      UpdateNoteUsecase(_repository).call(params: params);

  Future<Result> deleteNote(String id) =>
      DeleteNoteUsecase(_repository).call(params: ByIdParams(id: id));
}
