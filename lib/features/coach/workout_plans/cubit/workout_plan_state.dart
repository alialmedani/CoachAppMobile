part of 'workout_plan_cubit.dart';

@immutable
abstract class WorkoutPlanState {}

class WorkoutPlanInitial extends WorkoutPlanState {}

/// Emitted on search / filter change to rebuild the search field and chips
/// (documented list-UI emit exception; not API state).
class WorkoutPlanSearchChanged extends WorkoutPlanState {}
