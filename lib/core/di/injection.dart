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
  // TODO(CoachApp): register feature cubits here as features are added under lib/features/.
}
