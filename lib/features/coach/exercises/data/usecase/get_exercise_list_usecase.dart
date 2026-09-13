import 'package:coachappmobile/core/boilerplate/pagination/models/get_list_request.dart';
import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/exercise_model.dart';
import '../repository/exercise_repository.dart';

/// Query for the exercise library (ABP `GetExerciseListInput`).
class GetExerciseListParams extends BaseParams {
  final GetListRequest? request;
  final String? filter;
  final int? targetMuscle;
  final int? equipment;
  final bool? isActive;

  GetExerciseListParams({
    this.request,
    this.filter,
    this.targetMuscle,
    this.equipment,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (request?.skip != null) map['SkipCount'] = request!.skip;
    if (request?.take != null) map['MaxResultCount'] = request!.take;
    if (filter != null && filter!.isNotEmpty) map['Filter'] = filter;
    if (targetMuscle != null) map['TargetMuscle'] = targetMuscle;
    if (equipment != null) map['Equipment'] = equipment;
    if (isActive != null) map['IsActive'] = isActive;
    return map;
  }
}

class GetExerciseListUsecase
    extends UseCase<List<ExerciseModel>, GetExerciseListParams> {
  final ExerciseRepository repository;

  GetExerciseListUsecase(this.repository);

  @override
  Future<Result<List<ExerciseModel>>> call({
    required GetExerciseListParams params,
  }) {
    return repository.getExerciseListRequest(params: params);
  }
}
