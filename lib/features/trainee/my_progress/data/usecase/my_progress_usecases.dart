import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/coach/tracking/data/model/progress_entry_model.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';

import '../params/create_my_progress_params.dart';
import '../repository/my_progress_repository.dart';

class GetMyProgressListUsecase
    extends UseCase<List<ProgressEntryModel>, NoParams> {
  final MyProgressRepository repository;

  GetMyProgressListUsecase(this.repository);

  @override
  Future<Result<List<ProgressEntryModel>>> call({required NoParams params}) =>
      repository.getRecentRequest();
}

class CreateMyProgressUsecase
    extends UseCase<ProgressEntryModel, CreateMyProgressParams> {
  final MyProgressRepository repository;

  CreateMyProgressUsecase(this.repository);

  @override
  Future<Result<ProgressEntryModel>> call({
    required CreateMyProgressParams params,
  }) => repository.createRequest(params: params);
}

class UpdateMyProgressUsecase
    extends UseCase<ProgressEntryModel, UpdateMyProgressParams> {
  final MyProgressRepository repository;

  UpdateMyProgressUsecase(this.repository);

  @override
  Future<Result<ProgressEntryModel>> call({
    required UpdateMyProgressParams params,
  }) => repository.updateRequest(params: params);
}

class DeleteMyProgressUsecase extends UseCase<String, ByIdParams> {
  final MyProgressRepository repository;

  DeleteMyProgressUsecase(this.repository);

  @override
  Future<Result<String>> call({required ByIdParams params}) =>
      repository.deleteRequest(id: params.id);
}
