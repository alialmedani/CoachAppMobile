/// Dart mirrors of the CoachApp backend enums used by the trainee profile.
///
/// Both are serialized by the backend as **integers** (verified against
/// `GET /api/app/trainee`), so [value] is the wire value and [labelKey] is the
/// snake_case translation key for display. Keep the integer values in lock-step
/// with `C:\src\BACK\CoachApp\src\CoachApp.Domain.Shared\Enums`.
library;

/// Trainee gender (backend `Gender : byte`).
enum Gender {
  unspecified(0, 'gender_unspecified'),
  male(1, 'gender_male'),
  female(2, 'gender_female');

  const Gender(this.value, this.labelKey);

  final int value;
  final String labelKey;

  static Gender fromValue(int? value) => Gender.values.firstWhere(
    (g) => g.value == value,
    orElse: () => Gender.unspecified,
  );
}

/// Trainee primary training goal (backend `TrainingGoal : byte`).
enum TrainingGoal {
  general(0, 'goal_general'),
  loseWeight(1, 'goal_lose_weight'),
  buildMuscle(2, 'goal_build_muscle'),
  maintain(3, 'goal_maintain'),
  improveFitness(4, 'goal_improve_fitness'),
  strength(5, 'goal_strength');

  const TrainingGoal(this.value, this.labelKey);

  final int value;
  final String labelKey;

  static TrainingGoal fromValue(int? value) => TrainingGoal.values.firstWhere(
    (g) => g.value == value,
    orElse: () => TrainingGoal.general,
  );
}
