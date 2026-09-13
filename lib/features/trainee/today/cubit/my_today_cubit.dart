import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/results/result.dart';

import '../data/repository/my_today_repository.dart';
import '../data/usecase/get_my_today_usecase.dart';

part 'my_today_state.dart';

/// Orchestrates the trainee's Today screen. The [GetModel] boilerplate owns the
/// async UI state; this cubit computes the local date and calls the usecase.
class MyTodayCubit extends Cubit<MyTodayState> {
  MyTodayCubit() : super(MyTodayInitial());

  final MyTodayRepository _repository = MyTodayRepository();

  /// Today in the device's LOCAL timezone as ISO `yyyy-MM-dd`, so the server's
  /// "today" matches what the trainee sees on their clock (not server UTC).
  static String localToday() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }

  Future<Result> fetchToday() =>
      GetMyTodayUsecase(_repository)
          .call(params: GetMyTodayParams(localDate: localToday()));
}
