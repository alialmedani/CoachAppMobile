import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';
import 'package:coachappmobile/features/coach/tracking/data/model/trainee_dashboard_model.dart';

import '../repository/my_dashboard_repository.dart';

class MyDashboardParams extends BaseParams {
  final String date;
  final String fromDate;
  final String toDate;

  MyDashboardParams({
    required this.date,
    required this.fromDate,
    required this.toDate,
  });
}

class GetMyDashboardUsecase
    extends UseCase<TraineeDashboardModel, MyDashboardParams> {
  final MyDashboardRepository repository;

  GetMyDashboardUsecase(this.repository);

  @override
  Future<Result<TraineeDashboardModel>> call({
    required MyDashboardParams params,
  }) => repository.getSummaryRequest(
    date: params.date,
    fromDate: params.fromDate,
    toDate: params.toDate,
  );
}
