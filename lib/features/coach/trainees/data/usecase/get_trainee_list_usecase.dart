import 'package:coachappmobile/core/boilerplate/pagination/models/get_list_request.dart';
import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/trainee_model.dart';
import '../repository/trainee_repository.dart';

/// Query for the coach trainees list. Maps to ABP `GetTraineeListInput`
/// (`SkipCount` / `MaxResultCount` + optional `Filter` / `Goal` / `IsActive`).
class GetTraineeListParams extends BaseParams {
  final GetListRequest? request;
  final String? filter;
  final int? goal;
  final bool? isActive;

  GetTraineeListParams({this.request, this.filter, this.goal, this.isActive});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (request?.skip != null) map['SkipCount'] = request!.skip;
    if (request?.take != null) map['MaxResultCount'] = request!.take;
    if (filter != null && filter!.isNotEmpty) map['Filter'] = filter;
    if (goal != null) map['Goal'] = goal;
    if (isActive != null) map['IsActive'] = isActive;
    return map;
  }
}

class GetTraineeListUsecase
    extends UseCase<List<TraineeModel>, GetTraineeListParams> {
  final TraineeRepository repository;

  GetTraineeListUsecase(this.repository);

  @override
  Future<Result<List<TraineeModel>>> call({
    required GetTraineeListParams params,
  }) {
    return repository.getTraineeListRequest(params: params);
  }
}
