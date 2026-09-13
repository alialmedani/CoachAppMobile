/// Dart mirrors of the backend `MuscleGroup` / `Equipment` enums (both `byte`,
/// serialized as integers). Keep values in lock-step with
/// `C:\src\BACK\CoachApp\src\CoachApp.Domain.Shared\Enums`.
library;

/// Primary muscle group an exercise targets.
enum MuscleGroup {
  other(0, 'muscle_other'),
  chest(1, 'muscle_chest'),
  back(2, 'muscle_back'),
  shoulders(3, 'muscle_shoulders'),
  arms(4, 'muscle_arms'),
  legs(5, 'muscle_legs'),
  core(6, 'muscle_core'),
  fullBody(7, 'muscle_full_body'),
  cardio(8, 'muscle_cardio');

  const MuscleGroup(this.value, this.labelKey);

  final int value;
  final String labelKey;

  static MuscleGroup fromValue(int? value) => MuscleGroup.values.firstWhere(
    (m) => m.value == value,
    orElse: () => MuscleGroup.other,
  );
}

/// Equipment an exercise requires.
enum Equipment {
  none(0, 'equip_none'),
  bodyweight(1, 'equip_bodyweight'),
  barbell(2, 'equip_barbell'),
  dumbbell(3, 'equip_dumbbell'),
  machine(4, 'equip_machine'),
  cable(5, 'equip_cable'),
  kettlebell(6, 'equip_kettlebell'),
  resistanceBand(7, 'equip_resistance_band'),
  other(8, 'equip_other');

  const Equipment(this.value, this.labelKey);

  final int value;
  final String labelKey;

  static Equipment fromValue(int? value) => Equipment.values.firstWhere(
    (e) => e.value == value,
    orElse: () => Equipment.none,
  );
}
