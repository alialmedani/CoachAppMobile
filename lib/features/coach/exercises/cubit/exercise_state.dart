part of 'exercise_cubit.dart';

@immutable
abstract class ExerciseState {}

class ExerciseInitial extends ExerciseState {}

/// Emitted on search / filter change to rebuild the search field and chips
/// (documented list-UI emit exception; not API state).
class ExerciseSearchChanged extends ExerciseState {}
