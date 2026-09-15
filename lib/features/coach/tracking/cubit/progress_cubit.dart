import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/boilerplate/pagination/models/get_list_request.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';

import '../data/params/progress_entry_params.dart';
import '../data/params/tracking_list_input.dart';
import '../data/repository/progress_entry_repository.dart';
import '../data/usecase/progress_usecases.dart';

part 'progress_state.dart';

/// Orchestrates the coach's CRUD of one trainee's progress entries.
class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit() : super(ProgressInitial());

  final ProgressEntryRepository _repository = ProgressEntryRepository();
  String _traineeId = '';

  String get traineeId => _traineeId;
  void setTrainee(String id) => _traineeId = id;

  /// Recent entries (newest first) — enough to drive the trend chart + list.
  Future<Result> fetchRecent() => GetProgressListUsecase(_repository).call(
    params: TrackingListInput(
      request: GetListRequest(skip: 0, take: 100),
      traineeId: _traineeId,
      sorting: 'Date desc',
    ),
  );

  Future<Result> createEntry(CreateUpdateProgressEntryParams params) =>
      CreateProgressUsecase(_repository).call(params: params);

  Future<Result> updateEntry(CreateUpdateProgressEntryParams params) =>
      UpdateProgressUsecase(_repository).call(params: params);

  Future<Result> deleteEntry(String id) =>
      DeleteProgressUsecase(_repository).call(params: ByIdParams(id: id));
}
