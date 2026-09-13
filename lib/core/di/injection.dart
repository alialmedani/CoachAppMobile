import 'package:coachappmobile/features/auth/cubit/session_cubit.dart';
import 'package:coachappmobile/features/coach/exercises/cubit/exercise_cubit.dart';
import 'package:coachappmobile/features/coach/foods/cubit/food_cubit.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/cubit/nutrition_plan_cubit.dart';
import 'package:coachappmobile/features/coach/trainees/cubit/trainee_cubit.dart';
import 'package:coachappmobile/features/coach/workout_plans/cubit/workout_plan_cubit.dart';
import 'package:coachappmobile/features/trainee/my_nutrition_plans/cubit/my_nutrition_plan_cubit.dart';
import 'package:coachappmobile/features/trainee/my_workout_plans/cubit/my_workout_plan_cubit.dart';
import 'package:coachappmobile/features/trainee/today/cubit/my_today_cubit.dart';
import 'package:get_it/get_it.dart';

/// Global service locator. Call [setUp] once from `main()` before `runApp`.
///
/// Register each feature Cubit here as you build it, e.g.:
/// ```dart
/// getIt.registerLazySingleton(() => TraineeCubit());
/// getIt.registerLazySingleton(() => WorkoutPlanCubit());
/// ```
/// then expose it in `main.dart`'s `MultiBlocProvider`.
final getIt = GetIt.instance;

Future<void> setUp() async {
  // App-level session/auth holder (Phase 1).
  getIt.registerLazySingleton(() => SessionCubit());

  // Feature cubits — provided per-screen/tab via BlocProvider(create:).
  // Factories so each provider owns a fresh instance (closed on dispose).
  getIt.registerFactory(() => TraineeCubit());
  getIt.registerFactory(() => ExerciseCubit());
  getIt.registerFactory(() => FoodCubit());
  getIt.registerFactory(() => WorkoutPlanCubit());
  getIt.registerFactory(() => NutritionPlanCubit());

  // Trainee (self-service) feature cubits.
  getIt.registerFactory(() => MyWorkoutPlanCubit());
  getIt.registerFactory(() => MyNutritionPlanCubit());
  getIt.registerFactory(() => MyTodayCubit());
  // TODO(CoachApp): register the rest of the feature cubits here as features
  // are added under lib/features/.
}
