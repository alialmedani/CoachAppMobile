/// Dart mirror of `CoachApp.Application.Contracts/Permissions/CoachAppPermissions.cs`.
///
/// These strings are checked against the `auth.grantedPolicies` map returned by
/// `api/abp/application-configuration` (see [SessionModel.can]). Keep this file
/// in lock-step with the backend permission tree — when the backend adds a
/// policy, mirror it here in the same change.
///
/// Note the `CoachApp` group prefix on every node.
class CoachAppPermissions {
  CoachAppPermissions._();

  /// Permission group name (ABP feature/permission group).
  static const String groupName = 'CoachApp';
}

/// Management side — granted to the `Coach` role / tenant admin.
class CoachPermissions {
  CoachPermissions._();

  /// Common prefix of every coach-side policy. Used to detect "any coach
  /// capability" for role routing (F20).
  static const String coachPrefix = 'CoachApp.Coach.';

  // Trainees
  static const String trainees = 'CoachApp.Coach.Trainees';
  static const String traineesCreate = 'CoachApp.Coach.Trainees.Create';
  static const String traineesUpdate = 'CoachApp.Coach.Trainees.Update';
  static const String traineesDelete = 'CoachApp.Coach.Trainees.Delete';
  static const String traineesResetPassword =
      'CoachApp.Coach.Trainees.ResetPassword';

  // Exercises
  static const String exercises = 'CoachApp.Coach.Exercises';
  static const String exercisesCreate = 'CoachApp.Coach.Exercises.Create';
  static const String exercisesUpdate = 'CoachApp.Coach.Exercises.Update';
  static const String exercisesDelete = 'CoachApp.Coach.Exercises.Delete';

  // Workout plans
  static const String workoutPlans = 'CoachApp.Coach.WorkoutPlans';
  static const String workoutPlansCreate = 'CoachApp.Coach.WorkoutPlans.Create';
  static const String workoutPlansUpdate = 'CoachApp.Coach.WorkoutPlans.Update';
  static const String workoutPlansDelete = 'CoachApp.Coach.WorkoutPlans.Delete';

  // Workout plan templates
  static const String workoutPlanTemplates =
      'CoachApp.Coach.WorkoutPlanTemplates';
  static const String workoutPlanTemplatesCreate =
      'CoachApp.Coach.WorkoutPlanTemplates.Create';
  static const String workoutPlanTemplatesUpdate =
      'CoachApp.Coach.WorkoutPlanTemplates.Update';
  static const String workoutPlanTemplatesDelete =
      'CoachApp.Coach.WorkoutPlanTemplates.Delete';

  // Foods
  static const String foods = 'CoachApp.Coach.Foods';
  static const String foodsCreate = 'CoachApp.Coach.Foods.Create';
  static const String foodsUpdate = 'CoachApp.Coach.Foods.Update';
  static const String foodsDelete = 'CoachApp.Coach.Foods.Delete';

  // Nutrition plans
  static const String nutritionPlans = 'CoachApp.Coach.NutritionPlans';
  static const String nutritionPlansCreate =
      'CoachApp.Coach.NutritionPlans.Create';
  static const String nutritionPlansUpdate =
      'CoachApp.Coach.NutritionPlans.Update';
  static const String nutritionPlansDelete =
      'CoachApp.Coach.NutritionPlans.Delete';

  // Nutrition plan templates
  static const String nutritionPlanTemplates =
      'CoachApp.Coach.NutritionPlanTemplates';
  static const String nutritionPlanTemplatesCreate =
      'CoachApp.Coach.NutritionPlanTemplates.Create';
  static const String nutritionPlanTemplatesUpdate =
      'CoachApp.Coach.NutritionPlanTemplates.Update';
  static const String nutritionPlanTemplatesDelete =
      'CoachApp.Coach.NutritionPlanTemplates.Delete';

  // Tracking (default-only: view a trainee's logs and progress)
  static const String tracking = 'CoachApp.Coach.Tracking';

  // Progress
  static const String progress = 'CoachApp.Coach.Progress';
  static const String progressCreate = 'CoachApp.Coach.Progress.Create';
  static const String progressUpdate = 'CoachApp.Coach.Progress.Update';
  static const String progressDelete = 'CoachApp.Coach.Progress.Delete';

  // Notes
  static const String notes = 'CoachApp.Coach.Notes';
  static const String notesCreate = 'CoachApp.Coach.Notes.Create';
  static const String notesUpdate = 'CoachApp.Coach.Notes.Update';
  static const String notesDelete = 'CoachApp.Coach.Notes.Delete';
}

/// Self-service side — granted to the `Trainee` role.
class TraineePermissions {
  TraineePermissions._();

  static const String myProfile = 'CoachApp.Trainee.MyProfile';
  static const String myDashboard = 'CoachApp.Trainee.MyDashboard';
  static const String myToday = 'CoachApp.Trainee.MyToday';
  static const String myWorkoutPlans = 'CoachApp.Trainee.MyWorkoutPlans';

  // Workout logs
  static const String workoutLogs = 'CoachApp.Trainee.WorkoutLogs';
  static const String workoutLogsCreate =
      'CoachApp.Trainee.WorkoutLogs.Create';
  static const String workoutLogsUpdate =
      'CoachApp.Trainee.WorkoutLogs.Update';

  static const String myNutritionPlans = 'CoachApp.Trainee.MyNutritionPlans';

  // Nutrition logs
  static const String nutritionLogs = 'CoachApp.Trainee.NutritionLogs';
  static const String nutritionLogsCreate =
      'CoachApp.Trainee.NutritionLogs.Create';
  static const String nutritionLogsUpdate =
      'CoachApp.Trainee.NutritionLogs.Update';

  // Progress
  static const String myProgress = 'CoachApp.Trainee.MyProgress';
  static const String myProgressCreate = 'CoachApp.Trainee.MyProgress.Create';

  static const String myNotes = 'CoachApp.Trainee.MyNotes';
}
