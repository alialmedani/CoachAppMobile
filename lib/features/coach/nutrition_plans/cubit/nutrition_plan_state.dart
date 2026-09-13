part of 'nutrition_plan_cubit.dart';

@immutable
abstract class NutritionPlanState {}

class NutritionPlanInitial extends NutritionPlanState {}

/// Emitted on search / filter change to rebuild the search field and chips
/// (documented list-UI emit exception; not API state).
class NutritionPlanSearchChanged extends NutritionPlanState {}
