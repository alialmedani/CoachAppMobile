import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';

import '../model/progress_entry_model.dart';
import '../params/progress_entry_params.dart';
import '../params/tracking_list_input.dart';
import '../repository/progress_entry_repository.dart';

class GetProgressListUsecase
    extends UseCase<List<ProgressEntryModel>, TrackingListInput> {
  final ProgressEntryRepository repository;

  GetProgressListUsecase(this.repository);

  @override
  Future<Result<List<ProgressEntryModel>>> call({
    required TrackingListInput params,
  }) => repository.getListRequest(params: params);
}

class CreateProgressUsecase
    extends UseCase<ProgressEntryModel, CreateUpdateProgressEntryParams> {
  final ProgressEntryRepository repository;

  CreateProgressUsecase(this.repository);

  @override
  Future<Result<ProgressEntryModel>> call({
    required CreateUpdateProgressEntryParams params,
  }) => repository.createRequest(params: params);
}

class UpdateProgressUsecase
    extends UseCase<ProgressEntryModel, CreateUpdateProgressEntryParams> {
  final ProgressEntryRepository repository;

  UpdateProgressUsecase(this.repository);

  @override
  Future<Result<ProgressEntryModel>> call({
    required CreateUpdateProgressEntryParams params,
  }) => repository.updateRequest(params: params);
}

class DeleteProgressUsecase extends UseCase<String, ByIdParams> {
  final ProgressEntryRepository repository;

  DeleteProgressUsecase(this.repository);

  @override
  Future<Result<String>> call({required ByIdParams params}) =>
      repository.deleteRequest(id: params.id);
}
