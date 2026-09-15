import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';

import '../model/trainee_note_model.dart';
import '../params/trainee_note_params.dart';
import '../params/tracking_list_input.dart';
import '../repository/trainee_note_repository.dart';

class GetNoteListUsecase
    extends UseCase<List<TraineeNoteModel>, TrackingListInput> {
  final TraineeNoteRepository repository;

  GetNoteListUsecase(this.repository);

  @override
  Future<Result<List<TraineeNoteModel>>> call({
    required TrackingListInput params,
  }) => repository.getListRequest(params: params);
}

class CreateNoteUsecase
    extends UseCase<TraineeNoteModel, CreateUpdateTraineeNoteParams> {
  final TraineeNoteRepository repository;

  CreateNoteUsecase(this.repository);

  @override
  Future<Result<TraineeNoteModel>> call({
    required CreateUpdateTraineeNoteParams params,
  }) => repository.createRequest(params: params);
}

class UpdateNoteUsecase
    extends UseCase<TraineeNoteModel, CreateUpdateTraineeNoteParams> {
  final TraineeNoteRepository repository;

  UpdateNoteUsecase(this.repository);

  @override
  Future<Result<TraineeNoteModel>> call({
    required CreateUpdateTraineeNoteParams params,
  }) => repository.updateRequest(params: params);
}

class DeleteNoteUsecase extends UseCase<String, ByIdParams> {
  final TraineeNoteRepository repository;

  DeleteNoteUsecase(this.repository);

  @override
  Future<Result<String>> call({required ByIdParams params}) =>
      repository.deleteRequest(id: params.id);
}
