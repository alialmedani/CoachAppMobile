/// A trainee's workout completion over a date range (mirrors backend
/// `WorkoutCompletionDto`): planned vs completed sessions and the uncapped %.
class WorkoutCompletionModel {
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool hasActivePlan;
  final int? plannedPerWeek;
  final int weeks;
  final int? plannedSessions;
  final int completedSessions;
  final double? completionPercent;

  WorkoutCompletionModel({
    this.fromDate,
    this.toDate,
    this.hasActivePlan = false,
    this.plannedPerWeek,
    this.weeks = 1,
    this.plannedSessions,
    this.completedSessions = 0,
    this.completionPercent,
  });

  factory WorkoutCompletionModel.fromJson(Map<String, dynamic> json) {
    return WorkoutCompletionModel(
      fromDate: json['fromDate'] != null
          ? DateTime.tryParse(json['fromDate'])
          : null,
      toDate: json['toDate'] != null ? DateTime.tryParse(json['toDate']) : null,
      hasActivePlan: json['hasActivePlan'] ?? false,
      plannedPerWeek: json['plannedPerWeek'],
      weeks: json['weeks'] ?? 1,
      plannedSessions: json['plannedSessions'],
      completedSessions: json['completedSessions'] ?? 0,
      completionPercent: (json['completionPercent'] as num?)?.toDouble(),
    );
  }
}
