import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_day_model.dart';

/// A trainee's logged workout session (mirrors backend `WorkoutLogDto`).
///
/// Each entry pairs the trainee's **actual** performance (sets/reps/weight)
/// with the **prescribed** snapshot captured from the plan at log time
/// (`prescribed*`, null for manual off-plan logs). Prescribed fields are
/// server-owned and read-only — the update DTO has no prescribed fields, and
/// the server re-attaches the snapshot by matching `(exerciseId, order)`.
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

  /// Builds an **unsaved** draft log from a plan [day], seeding each entry's
  /// actuals from the prescribed snapshot. Lets the log editor open and edit
  /// actuals WITHOUT creating anything server-side — the log is POSTed
  /// (from-day) only on Save, so backing out leaves no phantom log.
  factory WorkoutLogModel.draftFromDay(WorkoutDayModel day) {
    return WorkoutLogModel(
      workoutDayId: day.id,
      entries: [
        for (final ex in day.exercises)
          WorkoutLogEntryModel(
            exerciseId: ex.exerciseId,
            exerciseName: ex.exerciseName,
            order: ex.order,
            sets: ex.sets,
            reps: ex.reps,
            weightKg: ex.weightKg,
            prescribedSets: ex.sets,
            prescribedReps: ex.reps,
            prescribedWeightKg: ex.weightKg,
          ),
      ],
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

  /// Whether this entry carries a prescribed snapshot (from-plan/from-day log).
  bool get hasPrescribed =>
      prescribedSets != null ||
      (prescribedReps != null && prescribedReps!.isNotEmpty) ||
      prescribedWeightKg != null;

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

  /// Write shape for `UpdateWorkoutLogEntryDto` — **actual fields only**. The
  /// original [exerciseId] and [order] MUST be preserved so the server can
  /// re-match the prescribed snapshot; `prescribed*` are never sent.
  Map<String, dynamic> toWriteJson() {
    return {
      'exerciseId': exerciseId,
      'order': order,
      'sets': sets,
      if (reps != null && reps!.trim().isNotEmpty) 'reps': reps!.trim(),
      if (weightKg != null) 'weightKg': weightKg,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }

  WorkoutLogEntryModel copyWith({
    int? sets,
    String? reps,
    double? weightKg,
    String? notes,
  }) {
    return WorkoutLogEntryModel(
      id: id,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      order: order,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      notes: notes ?? this.notes,
      prescribedSets: prescribedSets,
      prescribedReps: prescribedReps,
      prescribedWeightKg: prescribedWeightKg,
    );
  }
}
