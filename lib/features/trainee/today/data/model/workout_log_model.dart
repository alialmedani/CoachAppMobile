/// A trainee's logged workout session (mirrors backend `WorkoutLogDto`).
///
/// Each entry pairs the trainee's **actual** performance (sets/reps/weight)
/// with the **prescribed** snapshot captured from the plan at log time
/// (`prescribed*`, null for manual off-plan logs). On Today this is the
/// `latestWorkoutLog` shown read-only.
class WorkoutLogModel {
  final String? id;
  final String? traineeId;
  final String? workoutPlanId;
  final String? workoutDayId;
  final DateTime? date;
  final String? notes;
  final List<WorkoutLogEntryModel> entries;

  WorkoutLogModel({
    this.id,
    this.traineeId,
    this.workoutPlanId,
    this.workoutDayId,
    this.date,
    this.notes,
    this.entries = const [],
  });

  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) {
    final rawEntries = json['entries'] as List<dynamic>? ?? [];
    return WorkoutLogModel(
      id: json['id']?.toString(),
      traineeId: json['traineeId']?.toString(),
      workoutPlanId: json['workoutPlanId']?.toString(),
      workoutDayId: json['workoutDayId']?.toString(),
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      notes: json['notes'],
      entries: rawEntries
          .map((e) => WorkoutLogEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// One logged exercise inside a [WorkoutLogModel] (mirrors backend
/// `WorkoutLogEntryDto`).
class WorkoutLogEntryModel {
  final String? id;
  final String? exerciseId;
  final String? exerciseName;
  final int order;
  final int sets;
  final String? reps;
  final double? weightKg;
  final String? notes;
  final int? prescribedSets;
  final String? prescribedReps;
  final double? prescribedWeightKg;

  WorkoutLogEntryModel({
    this.id,
    this.exerciseId,
    this.exerciseName,
    this.order = 0,
    this.sets = 0,
    this.reps,
    this.weightKg,
    this.notes,
    this.prescribedSets,
    this.prescribedReps,
    this.prescribedWeightKg,
  });

  factory WorkoutLogEntryModel.fromJson(Map<String, dynamic> json) {
    return WorkoutLogEntryModel(
      id: json['id']?.toString(),
      exerciseId: json['exerciseId']?.toString(),
      exerciseName: json['exerciseName'],
      order: json['order'] ?? 0,
      sets: json['sets'] ?? 0,
      reps: json['reps'],
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      notes: json['notes'],
      prescribedSets: json['prescribedSets'],
      prescribedReps: json['prescribedReps'],
      prescribedWeightKg: (json['prescribedWeightKg'] as num?)?.toDouble(),
    );
  }
}
