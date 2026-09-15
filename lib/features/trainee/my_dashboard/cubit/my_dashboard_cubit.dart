import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/results/result.dart';

import '../data/repository/my_dashboard_repository.dart';
import '../data/usecase/my_dashboard_usecase.dart';

part 'my_dashboard_state.dart';

/// Orchestrates the trainee's own dashboard. Boilerplate widgets own the async
/// UI state.
class MyDashboardCubit extends Cubit<MyDashboardState> {
  MyDashboardCubit() : super(MyDashboardInitial());

  final MyDashboardRepository _repository = MyDashboardRepository();

  static String _iso(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  /// Adherence for today + completion over the trailing 4 weeks.
  Future<Result> fetchSummary() {
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 27));
    return GetMyDashboardUsecase(_repository).call(
      params: MyDashboardParams(
        date: _iso(now),
        fromDate: _iso(from),
        toDate: _iso(now),
      ),
    );
  }
}
