import 'package:coachappmobile/features/coach/exercises/data/model/exercise_enums.dart';
import 'package:coachappmobile/features/coach/exercises/data/model/exercise_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for [ExerciseModel] + its [MuscleGroup]/[Equipment] enums, which
/// the backend serializes as integers (`byte`). The key contract: enums map to
/// their integer `value` on the wire and fall back safely on unknown values.
void main() {
  group('MuscleGroup / Equipment enums', () {
    test('fromValue maps the integer wire value', () {
      expect(MuscleGroup.fromValue(1), MuscleGroup.chest);
      expect(MuscleGroup.fromValue(5), MuscleGroup.legs);
      expect(Equipment.fromValue(2), Equipment.barbell);
      expect(Equipment.fromValue(3), Equipment.dumbbell);
    });

    test('fromValue falls back on null/unknown', () {
      expect(MuscleGroup.fromValue(null), MuscleGroup.other);
      expect(MuscleGroup.fromValue(999), MuscleGroup.other);
      expect(Equipment.fromValue(null), Equipment.none);
      expect(Equipment.fromValue(999), Equipment.none);
    });

    test('value is the integer wire value', () {
      expect(MuscleGroup.legs.value, 5);
      expect(Equipment.machine.value, 4);
    });
  });

  group('ExerciseModel.fromJson', () {
    test('parses enums from their integer values', () {
      final model = ExerciseModel.fromJson({
        'id': 'e-1',
        'name': 'Squat',
        'targetMuscle': 5, // legs
        'equipment': 2, // barbell
        'isActive': true,
      });

      expect(model.id, 'e-1');
      expect(model.name, 'Squat');
      expect(model.targetMuscle, MuscleGroup.legs);
      expect(model.equipment, Equipment.barbell);
      expect(model.isActive, isTrue);
    });

    test('applies enum defaults when missing', () {
      final model = ExerciseModel.fromJson({'name': 'x'});
      expect(model.targetMuscle, MuscleGroup.other);
      expect(model.equipment, Equipment.none);
      expect(model.isActive, isTrue);
    });
  });

  group('ExerciseModel.toJson', () {
    test('serializes enums back to their integer values', () {
      final json = ExerciseModel(
        id: 'e-2',
        name: 'Bench Press',
        targetMuscle: MuscleGroup.chest,
        equipment: Equipment.barbell,
      ).toJson();

      expect(json['targetMuscle'], 1);
      expect(json['equipment'], 2);
      expect(json['name'], 'Bench Press');
    });
  });

  test('round-trips through JSON preserving enums', () {
    final original = ExerciseModel(
      id: 'e-3',
      name: 'Row',
      description: 'Bent-over',
      instructions: 'Keep back flat',
      targetMuscle: MuscleGroup.back,
      equipment: Equipment.dumbbell,
      isActive: false,
    );

    final restored = ExerciseModel.fromJson(original.toJson());

    expect(restored.targetMuscle, MuscleGroup.back);
    expect(restored.equipment, Equipment.dumbbell);
    expect(restored.name, 'Row');
    expect(restored.description, 'Bent-over');
    expect(restored.instructions, 'Keep back flat');
    expect(restored.isActive, isFalse);
  });

  test('copyWith overrides only the given field', () {
    final base = ExerciseModel(id: 'e-4', name: 'Base');
    final copy = base.copyWith(targetMuscle: MuscleGroup.core);

    expect(copy.id, 'e-4');
    expect(copy.name, 'Base');
    expect(copy.targetMuscle, MuscleGroup.core);
    expect(base.targetMuscle, MuscleGroup.other);
  });
}
