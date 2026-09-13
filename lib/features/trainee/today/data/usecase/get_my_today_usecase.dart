import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/my_today_model.dart';
import '../repository/my_today_repository.dart';

/// Params for the Today query — the trainee's local date as ISO `yyyy-MM-dd`.
class GetMyTodayParams extends BaseParams {
  final String localDate;

  GetMyTodayParams({required this.localDate});
}

class GetMyTodayUsecase extends UseCase<MyTodayModel, GetMyTodayParams> {
  final MyTodayRepository repository;

  GetMyTodayUsecase(this.repository);

  @override
  Future<Result<MyTodayModel>> call({required GetMyTodayParams params}) {
    return repository.getMyTodayRequest(localDate: params.localDate);
  }
}
