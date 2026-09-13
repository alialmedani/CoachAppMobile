/// A single exercise entry inside a workout day (mirrors backend
/// `WorkoutExerciseDto`).
///
/// [exerciseName] is read-only display data enriched by the server from the
/// exercise library; it is never sent back on write. [reps] is a free-form
/// string (e.g. "8-12", "AMRAP"), and [weightKg] is a decimal parsed via
/// `(num?)?.toDouble()`.
class WorkoutExerciseModel {
  final String? id;
  final String? exerciseId;
  final String? exerciseName;
  final int order;
  final int sets;
  final String? reps;
  final double? weightKg;
  final int? restSeconds;
  final String? notes;

  WorkoutExerciseModel({
    this.id,
    this.exerciseId,
    this.exerciseName,
    this.order = 0,
    this.sets = 1,
    this.reps,
    this.weightKg,
    this.restSeconds,
    this.notes,
  });

  factory WorkoutExerciseModel.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseModel(
      id: json['id']?.toString(),
      exerciseId: json['exerciseId']?.toString(),
      exerciseName: json['exerciseName'],
      order: json['order'] ?? 0,
      sets: json['sets'] ?? 1,
      reps: json['reps'],
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      restSeconds: json['restSeconds'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'order': order,
      'sets': sets,
      'reps': reps,
      'weightKg': weightKg,
      'restSeconds': restSeconds,
      'notes': notes,
    };
  }

  /// Write shape for `CreateUpdateWorkoutExerciseDto` — no child `id`, no
  /// enriched `exerciseName`; [order] is taken from the list position.
  Map<String, dynamic> toWriteJson(int order) {
    return {
      'exerciseId': exerciseId,
      'order': order,
      'sets': sets,
      if (reps != null && reps!.trim().isNotEmpty) 'reps': reps!.trim(),
      if (weightKg != null) 'weightKg': weightKg,
      if (restSeconds != null) 'restSeconds': restSeconds,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }

  WorkoutExerciseModel copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    int? order,
    int? sets,
    String? reps,
    double? weightKg,
    int? restSeconds,
    String? notes,
  }) {
    return WorkoutExerciseModel(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      order: order ?? this.order,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      restSeconds: restSeconds ?? this.restSeconds,
      notes: notes ?? this.notes,
    );
  }
}
