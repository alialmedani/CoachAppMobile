import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_day_model.dart';
import 'package:coachappmobile/features/trainee/workout_logs/data/model/workout_log_model.dart';

import 'nutrition_adherence_model.dart';

/// The trainee's composed "Today" view (mirrors backend `MyTodayDto`) for a
/// given local date: today's scheduled workout, whether it's a rest day, the
/// latest workout log, the active nutrition plan, and nutrition adherence.
///
/// [date]/[dayOfWeek] are resolved server-side from the local date the client
/// sends. [scheduledWorkoutDays] reuses the coach [WorkoutDayModel] (same
/// `WorkoutDayDto`), and [nutritionPlan] the coach [NutritionPlanModel].
class MyTodayModel {
  final DateTime? date;
  final int? dayOfWeek;
  final bool hasActiveWorkoutPlan;
  final String? workoutPlanId;
  final bool isRestDay;
  final List<WorkoutDayModel> scheduledWorkoutDays;
  final bool alreadyLoggedWorkoutToday;
  final String? latestWorkoutLogId;
  final WorkoutLogModel? latestWorkoutLog;
  final bool hasActiveNutritionPlan;
  final NutritionPlanModel? nutritionPlan;
  final NutritionAdherenceModel nutritionAdherence;
  final bool alreadyLoggedNutritionToday;

  MyTodayModel({
    this.date,
    this.dayOfWeek,
    this.hasActiveWorkoutPlan = false,
    this.workoutPlanId,
    this.isRestDay = false,
    this.scheduledWorkoutDays = const [],
    this.alreadyLoggedWorkoutToday = false,
    this.latestWorkoutLogId,
    this.latestWorkoutLog,
    this.hasActiveNutritionPlan = false,
    this.nutritionPlan,
    NutritionAdherenceModel? nutritionAdherence,
    this.alreadyLoggedNutritionToday = false,
  }) : nutritionAdherence = nutritionAdherence ?? NutritionAdherenceModel();

  factory MyTodayModel.fromJson(Map<String, dynamic> json) {
    final rawDays = json['scheduledWorkoutDays'] as List<dynamic>? ?? [];
    return MyTodayModel(
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      dayOfWeek: json['dayOfWeek'],
      hasActiveWorkoutPlan: json['hasActiveWorkoutPlan'] ?? false,
      workoutPlanId: json['workoutPlanId']?.toString(),
      isRestDay: json['isRestDay'] ?? false,
      scheduledWorkoutDays: rawDays
          .map((e) => WorkoutDayModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      alreadyLoggedWorkoutToday: json['alreadyLoggedWorkoutToday'] ?? false,
      latestWorkoutLogId: json['latestWorkoutLogId']?.toString(),
      latestWorkoutLog: json['latestWorkoutLog'] != null
          ? WorkoutLogModel.fromJson(
              json['latestWorkoutLog'] as Map<String, dynamic>,
            )
          : null,
      hasActiveNutritionPlan: json['hasActiveNutritionPlan'] ?? false,
      nutritionPlan: json['nutritionPlan'] != null
          ? NutritionPlanModel.fromJson(
              json['nutritionPlan'] as Map<String, dynamic>,
            )
          : null,
      nutritionAdherence: json['nutritionAdherence'] != null
          ? NutritionAdherenceModel.fromJson(
              json['nutritionAdherence'] as Map<String, dynamic>,
            )
          : NutritionAdherenceModel(),
      alreadyLoggedNutritionToday: json['alreadyLoggedNutritionToday'] ?? false,
    );
  }
}
