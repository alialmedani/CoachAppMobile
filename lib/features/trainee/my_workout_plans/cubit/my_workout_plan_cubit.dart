import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';

import '../data/repository/my_workout_plan_repository.dart';
import '../data/usecase/get_my_workout_plan_usecase.dart';
import '../data/usecase/get_my_workout_plans_usecase.dart';

part 'my_workout_plan_state.dart';

/// Orchestrates the trainee's read-only workout-plan screens. The boilerplate
/// [GetModel] widgets own the Loading/Success/Error state from the returned
/// `Result`, so this cubit never calls `emit` for API state.
class MyWorkoutPlanCubit extends Cubit<MyWorkoutPlanState> {
  MyWorkoutPlanCubit() : super(MyWorkoutPlanInitial());

  final MyWorkoutPlanRepository _repository = MyWorkoutPlanRepository();

  Future<Result> fetchMyWorkoutPlans() =>
      GetMyWorkoutPlansUsecase(_repository).call(params: NoParams());

  Future<Result> fetchMyWorkoutPlanById(String id) =>
      GetMyWorkoutPlanUsecase(_repository).call(params: ByIdParams(id: id));
}
