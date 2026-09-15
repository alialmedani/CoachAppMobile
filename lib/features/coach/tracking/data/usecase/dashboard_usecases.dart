import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/trainee_dashboard_model.dart';
import '../repository/coach_dashboard_repository.dart';

/// Params for the coach dashboard summary (all ISO-8601 dates).
class DashboardSummaryParams extends BaseParams {
  final String traineeId;
  final String date;
  final String fromDate;
  final String toDate;

  DashboardSummaryParams({
    required this.traineeId,
    required this.date,
    required this.fromDate,
    required this.toDate,
  });
}

class GetTraineeDashboardUsecase
    extends UseCase<TraineeDashboardModel, DashboardSummaryParams> {
  final CoachDashboardRepository repository;

  GetTraineeDashboardUsecase(this.repository);

  @override
  Future<Result<TraineeDashboardModel>> call({
    required DashboardSummaryParams params,
  }) => repository.getSummaryRequest(
    traineeId: params.traineeId,
    date: params.date,
    fromDate: params.fromDate,
    toDate: params.toDate,
  );
}
