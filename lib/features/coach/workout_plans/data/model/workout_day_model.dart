import 'workout_enums.dart';
import 'workout_exercise_model.dart';

/// A training day inside a workout plan (mirrors backend `WorkoutDayDto`).
///
/// [order] is the day's position within the plan. [scheduledDay] is a nullable
/// [Weekday] — `null` means the day is unscheduled (not pinned to a weekday).
class WorkoutDayModel {
  final String? id;
  final String name;
  final int order;
  final Weekday? scheduledDay;
  final List<WorkoutExerciseModel> exercises;

  WorkoutDayModel({
    this.id,
    this.name = '',
    this.order = 0,
    this.scheduledDay,
    this.exercises = const [],
  });

  factory WorkoutDayModel.fromJson(Map<String, dynamic> json) {
    final rawExercises = json['exercises'] as List<dynamic>? ?? [];
    return WorkoutDayModel(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      order: json['order'] ?? 0,
      scheduledDay: Weekday.fromValue(json['scheduledDay']),
      exercises: rawExercises
          .map((e) => WorkoutExerciseModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'order': order,
      'scheduledDay': scheduledDay?.value,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  /// Write shape for `CreateUpdateWorkoutDayDto` — no child `id`; [order] is
  /// taken from the list position and children are re-indexed by position.
  Map<String, dynamic> toWriteJson(int order) {
    return {
      'name': name,
      'order': order,
      if (scheduledDay != null) 'scheduledDay': scheduledDay!.value,
      'exercises': [
        for (var i = 0; i < exercises.length; i++) exercises[i].toWriteJson(i),
      ],
    };
  }

  WorkoutDayModel copyWith({
    String? id,
    String? name,
    int? order,
    Weekday? scheduledDay,
    List<WorkoutExerciseModel>? exercises,
  }) {
    return WorkoutDayModel(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      scheduledDay: scheduledDay ?? this.scheduledDay,
      exercises: exercises ?? this.exercises,
    );
  }
}
