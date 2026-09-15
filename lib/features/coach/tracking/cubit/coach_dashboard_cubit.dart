import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/results/result.dart';

import '../data/repository/coach_dashboard_repository.dart';
import '../data/usecase/dashboard_usecases.dart';

part 'coach_dashboard_state.dart';

/// The adherence window the coach can pick on the dashboard (F5/PD5). Drives the
/// `FromDate`/`ToDate` range for both nutrition-range adherence and workout
/// completion; the single-day nutrition card always uses the anchor date (today).
enum CoachDashboardRange { today, thisWeek, last28Days }

/// Orchestrates the coach dashboard for one trainee. Boilerplate widgets own the
/// async UI state; no `emit` for API state — the selected [range] is plain
/// mutable state read by [fetchSummary].
class CoachDashboardCubit extends Cubit<CoachDashboardState> {
  CoachDashboardCubit() : super(CoachDashboardInitial());

  final CoachDashboardRepository _repository = CoachDashboardRepository();
  String _traineeId = '';

  /// Default window: the trailing week, so the weekly average (F5/PD5) is the
  /// headline view; the coach can switch to a single day or 28 days.
  CoachDashboardRange range = CoachDashboardRange.thisWeek;

  void setTrainee(String id) => _traineeId = id;

  /// Update the selected window (no emit — the screen rebuilds [fetchSummary]
  /// via a key derived from [range]).
  void setRange(CoachDashboardRange value) => range = value;

  static String isoDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  /// Inclusive number of days spanned by [range] (used for coverage labels).
  static int daysFor(CoachDashboardRange range) {
    switch (range) {
      case CoachDashboardRange.today:
        return 1;
      case CoachDashboardRange.thisWeek:
        return 7;
      case CoachDashboardRange.last28Days:
        return 28;
    }
  }

  /// Adherence for the anchor day (today) + range aggregates over the selected
  /// window (ending today).
  Future<Result> fetchSummary() {
    final now = DateTime.now();
    final from = now.subtract(Duration(days: daysFor(range) - 1));
    return GetTraineeDashboardUsecase(_repository).call(
      params: DashboardSummaryParams(
        traineeId: _traineeId,
        date: isoDate(now),
        fromDate: isoDate(from),
        toDate: isoDate(now),
      ),
    );
  }
}
