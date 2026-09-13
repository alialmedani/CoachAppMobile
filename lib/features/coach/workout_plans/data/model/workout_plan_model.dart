import 'workout_day_model.dart';

/// A coach-authored workout plan for a trainee (mirrors backend
/// `WorkoutPlanDto`).
///
/// The list endpoint returns **summaries with an empty [days] list**; the
/// single-get / create / update / set-active endpoints return the full tree
/// (days → exercises, with `exerciseName` enriched for display).
class WorkoutPlanModel {
  final String? id;
  final String? traineeId;
  final String? name;
  final String? description;
  final bool isActive;
  final List<WorkoutDayModel> days;
  final DateTime? creationTime;

  WorkoutPlanModel({
    this.id,
    this.traineeId,
    this.name,
    this.description,
    this.isActive = false,
    this.days = const [],
    this.creationTime,
  });

  /// Total training days (0 for list summaries, which don't load days).
  int get dayCount => days.length;

  factory WorkoutPlanModel.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'] as List<dynamic>? ?? [];
    return WorkoutPlanModel(
      id: json['id']?.toString(),
      traineeId: json['traineeId']?.toString(),
      name: json['name'],
      description: json['description'],
      isActive: json['isActive'] ?? false,
      days: rawDays.map((d) => WorkoutDayModel.fromJson(d)).toList(),
      creationTime: json['creationTime'] != null
          ? DateTime.tryParse(json['creationTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'traineeId': traineeId,
      'name': name,
      'description': description,
      'isActive': isActive,
      'days': days.map((d) => d.toJson()).toList(),
      'creationTime': creationTime?.toIso8601String(),
    };
  }

  WorkoutPlanModel copyWith({
    String? id,
    String? traineeId,
    String? name,
    String? description,
    bool? isActive,
    List<WorkoutDayModel>? days,
    DateTime? creationTime,
  }) {
    return WorkoutPlanModel(
      id: id ?? this.id,
      traineeId: traineeId ?? this.traineeId,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      days: days ?? this.days,
      creationTime: creationTime ?? this.creationTime,
    );
  }
}
