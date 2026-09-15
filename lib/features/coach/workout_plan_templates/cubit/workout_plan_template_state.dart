part of 'workout_plan_template_cubit.dart';

@immutable
abstract class WorkoutPlanTemplateState {}

class WorkoutPlanTemplateInitial extends WorkoutPlanTemplateState {}

/// Emitted on search change to rebuild the search field (documented list-UI emit
/// exception; not API state).
class WorkoutPlanTemplateSearchChanged extends WorkoutPlanTemplateState {}
