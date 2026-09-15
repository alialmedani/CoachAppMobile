import 'package:coachappmobile/features/coach/trainees/data/model/trainee_enums.dart';
import 'package:coachappmobile/features/coach/trainees/data/model/trainee_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for [TraineeModel] (the `TraineeDto`, reused as the trainee's own
/// `my-profile` DTO). Covers integer enum mapping (Gender/TrainingGoal), the
/// fullName/initial display getters, round-trip stability, and copyWith.
void main() {
  group('Gender / TrainingGoal enums', () {
    test('fromValue maps integer wire values', () {
      expect(Gender.fromValue(1), Gender.male);
      expect(Gender.fromValue(2), Gender.female);
      expect(TrainingGoal.fromValue(2), TrainingGoal.buildMuscle);
      expect(TrainingGoal.fromValue(5), TrainingGoal.strength);
    });

    test('fromValue falls back on null/unknown', () {
      expect(Gender.fromValue(null), Gender.unspecified);
      expect(Gender.fromValue(9), Gender.unspecified);
      expect(TrainingGoal.fromValue(null), TrainingGoal.general);
      expect(TrainingGoal.fromValue(9), TrainingGoal.general);
    });
  });

  group('TraineeModel.fromJson', () {
    test('parses a full profile with integer enums', () {
      final model = TraineeModel.fromJson({
        'id': 't-1',
        'userId': 'u-1',
        'userName': 'ahmed',
        'firstName': 'Ahmed',
        'lastName': 'Ali',
        'email': 'ahmed@example.com',
        'phoneNumber': '0700',
        'gender': 1, // male
        'birthDate': '2000-01-15T00:00:00',
        'goal': 2, // buildMuscle
        'heightCm': 180,
        'startWeightKg': 81.5,
        'targetWeightKg': 78,
        'isActive': true,
      });

      expect(model.id, 't-1');
      expect(model.userName, 'ahmed');
      expect(model.gender, Gender.male);
      expect(model.goal, TrainingGoal.buildMuscle);
      expect(model.birthDate, DateTime.parse('2000-01-15T00:00:00'));
      expect(model.heightCm, 180.0);
      expect(model.startWeightKg, 81.5);
      expect(model.targetWeightKg, 78.0);
      expect(model.isActive, isTrue);
    });

    test('defaults enums and leaves optional measures null', () {
      final model = TraineeModel.fromJson({'userName': 'x'});
      expect(model.gender, Gender.unspecified);
      expect(model.goal, TrainingGoal.general);
      expect(model.heightCm, isNull);
      expect(model.startWeightKg, isNull);
      expect(model.isActive, isTrue);
    });
  });

  group('display getters', () {
    test('fullName joins first + last', () {
      final m = TraineeModel(firstName: 'Ahmed', lastName: 'Ali');
      expect(m.fullName, 'Ahmed Ali');
    });

    test('fullName falls back to userName when name parts are empty', () {
      final m = TraineeModel(userName: 'ahmed', firstName: '  ', lastName: '');
      expect(m.fullName, 'ahmed');
    });

    test('initial is the uppercased first letter', () {
      expect(TraineeModel(firstName: 'ahmed').initial, 'A');
      expect(TraineeModel(userName: 'zed').initial, 'Z');
    });

    test('initial is "?" when there is nothing to show', () {
      expect(TraineeModel().initial, '?');
    });
  });

  test('toJson serializes enums to integers and round-trips', () {
    final original = TraineeModel(
      id: 't-2',
      userName: 'sara',
      firstName: 'Sara',
      gender: Gender.female,
      goal: TrainingGoal.loseWeight,
      heightCm: 165,
      startWeightKg: 62,
    );

    final json = original.toJson();
    expect(json['gender'], 2);
    expect(json['goal'], 1);

    final restored = TraineeModel.fromJson(json);
    expect(restored.gender, Gender.female);
    expect(restored.goal, TrainingGoal.loseWeight);
    expect(restored.userName, 'sara');
    expect(restored.heightCm, 165.0);
    expect(restored.startWeightKg, 62.0);
  });

  test('copyWith overrides only the given field', () {
    final base = TraineeModel(userName: 'ahmed', isActive: true);
    final copy = base.copyWith(isActive: false);
    expect(copy.userName, 'ahmed');
    expect(copy.isActive, isFalse);
    expect(base.isActive, isTrue);
  });
}
