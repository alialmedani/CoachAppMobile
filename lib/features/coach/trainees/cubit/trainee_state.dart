part of 'trainee_cubit.dart';

@immutable
abstract class TraineeState {}

class TraineeInitial extends TraineeState {}

/// Emitted when the search term or a list filter changes, so the search field
/// and filter chips rebuild. (The documented emit-exception for list UI state —
/// it is not API state; the boilerplate widgets own the request lifecycle.)
class TraineeSearchChanged extends TraineeState {}
