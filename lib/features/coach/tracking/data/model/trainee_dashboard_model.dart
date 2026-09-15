import 'package:coachappmobile/features/trainee/today/data/model/nutrition_adherence_model.dart';

import 'nutrition_adherence_range_model.dart';
import 'workout_completion_model.dart';

/// Coach dashboard summary for a trainee (mirrors backend `TraineeDashboardDto`)
/// — composes the day's nutrition adherence, the range's nutrition adherence
/// (F5/PD5 weekly view) and the range's workout completion. All sub-objects are
/// nullable (null when the trainee has no active plan/log). Reuses the shared
/// [NutritionAdherenceModel] (same DTO as Today / MyDashboard).
class TraineeDashboardModel {
  final String? traineeId;
  final NutritionAdherenceModel? nutritionAdherence;
  final NutritionAdherenceRangeModel? nutritionAdherenceRange;
  final WorkoutCompletionModel? workoutCompletion;

  TraineeDashboardModel({
    this.traineeId,
    this.nutritionAdherence,
    this.nutritionAdherenceRange,
    this.workoutCompletion,
  });

  factory TraineeDashboardModel.fromJson(Map<String, dynamic> json) {
    return TraineeDashboardModel(
      traineeId: json['traineeId']?.toString(),
      nutritionAdherence: json['nutritionAdherence'] != null
          ? NutritionAdherenceModel.fromJson(
              json['nutritionAdherence'] as Map<String, dynamic>,
            )
          : null,
      nutritionAdherenceRange: json['nutritionAdherenceRange'] != null
          ? NutritionAdherenceRangeModel.fromJson(
              json['nutritionAdherenceRange'] as Map<String, dynamic>,
            )
          : null,
      workoutCompletion: json['workoutCompletion'] != null
          ? WorkoutCompletionModel.fromJson(
              json['workoutCompletion'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}
