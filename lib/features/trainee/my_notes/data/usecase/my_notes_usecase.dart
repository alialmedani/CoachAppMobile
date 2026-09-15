import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/coach/tracking/data/model/trainee_note_model.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';

import '../repository/my_notes_repository.dart';

class GetMyNotesUsecase extends UseCase<List<TraineeNoteModel>, NoParams> {
  final MyNotesRepository repository;

  GetMyNotesUsecase(this.repository);

  @override
  Future<Result<List<TraineeNoteModel>>> call({required NoParams params}) =>
      repository.getRecentRequest();
}
