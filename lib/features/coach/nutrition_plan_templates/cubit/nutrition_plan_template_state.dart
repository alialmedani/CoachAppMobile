part of 'nutrition_plan_template_cubit.dart';

@immutable
abstract class NutritionPlanTemplateState {}

class NutritionPlanTemplateInitial extends NutritionPlanTemplateState {}

/// Emitted on search change to rebuild the search field (documented list-UI emit
/// exception; not API state).
class NutritionPlanTemplateSearchChanged extends NutritionPlanTemplateState {}
