part of 'food_cubit.dart';

@immutable
abstract class FoodState {}

class FoodInitial extends FoodState {}

/// Emitted on search change to rebuild the search field (list-UI exception).
class FoodSearchChanged extends FoodState {}
