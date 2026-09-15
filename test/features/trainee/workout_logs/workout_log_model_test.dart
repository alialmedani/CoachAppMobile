import 'package:coachappmobile/features/trainee/workout_logs/data/model/workout_log_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for [WorkoutLogModel] / [WorkoutLogEntryModel].
///
/// The critical invariant: on update, an entry's write shape carries **actual
/// fields only** and preserves `exerciseId` + `order` so the server can re-match
/// the prescribed snapshot — `prescribed*` are never sent. These tests lock that.
void main() {
  group('WorkoutLogModel.fromJson', () {
    test('parses the header and its nested entries', () {
      final log = WorkoutLogModel.fromJson({
        'id': 'wl-1',
        'traineeId': 't-1',
        'workoutPlanId': 'wp-1',
        'workoutDayId': 'wd-1',
        'date': '2026-09-13T00:00:00',
        'notes': 'felt strong',
        'entries': [
          {
            'id': 'we-1',
            'exerciseId': 'ex-1',
            'exerciseName': 'Squat',
            'order': 0,
            'sets': 5,
            'reps': '5',
            'weightKg': 100,
            'prescribedSets': 4,
            'prescribedReps': '5',
            'prescribedWeightKg': 95,
          },
        ],
      });

      expect(log.id, 'wl-1');
      expect(log.workoutDayId, 'wd-1');
      expect(log.date, DateTime.parse('2026-09-13T00:00:00'));
      expect(log.entries, hasLength(1));

      final e = log.entries.single;
      expect(e.exerciseId, 'ex-1');
      expect(e.order, 0);
      expect(e.sets, 5);
      expect(e.reps, '5');
      expect(e.weightKg, 100.0);
      expect(e.prescribedSets, 4);
      expect(e.prescribedWeightKg, 95.0);
    });

    test('defaults entries to an empty list when absent', () {
      final log = WorkoutLogModel.fromJson({'id': 'wl-2'});
      expect(log.entries, isEmpty);
    });
  });

  group('WorkoutLogEntryModel.hasPrescribed', () {
    test('is true when any prescribed field is present', () {
      expect(
        WorkoutLogEntryModel(prescribedSets: 4).hasPrescribed,
        isTrue,
      );
      expect(
        WorkoutLogEntryModel(prescribedReps: '8-10').hasPrescribed,
        isTrue,
      );
      expect(
        WorkoutLogEntryModel(prescribedWeightKg: 60).hasPrescribed,
        isTrue,
      );
    });

    test('is false for a manual (off-plan) entry with no snapshot', () {
      final e = WorkoutLogEntryModel(
        exerciseId: 'ex-9',
        order: 0,
        sets: 3,
        prescribedReps: '', // empty string does not count
      );
      expect(e.hasPrescribed, isFalse);
    });
  });

  group('WorkoutLogEntryModel.toWriteJson', () {
    test('emits actual fields only and preserves exerciseId + order', () {
      final e = WorkoutLogEntryModel(
        id: 'we-1',
        exerciseId: 'ex-1',
        exerciseName: 'Squat',
        order: 2,
        sets: 5,
        reps: '5',
        weightKg: 100,
        notes: 'PR',
        prescribedSets: 4,
        prescribedReps: '5',
        prescribedWeightKg: 95,
      );

      final json = e.toWriteJson();

      // actuals + identity preserved
      expect(json['exerciseId'], 'ex-1');
      expect(json['order'], 2);
      expect(json['sets'], 5);
      expect(json['reps'], '5');
      expect(json['weightKg'], 100.0);
      expect(json['notes'], 'PR');

      // prescribed snapshot NEVER written back
      expect(json.containsKey('prescribedSets'), isFalse);
      expect(json.containsKey('prescribedReps'), isFalse);
      expect(json.containsKey('prescribedWeightKg'), isFalse);
      // server-owned display/id fields not written
      expect(json.containsKey('exerciseName'), isFalse);
      expect(json.containsKey('id'), isFalse);
    });

    test('omits empty optional actuals', () {
      final e = WorkoutLogEntryModel(
        exerciseId: 'ex-2',
        order: 0,
        sets: 3,
        reps: '   ',
        notes: '',
      );
      final json = e.toWriteJson();

      expect(json['exerciseId'], 'ex-2');
      expect(json['order'], 0);
      expect(json['sets'], 3);
      expect(json.containsKey('reps'), isFalse);
      expect(json.containsKey('weightKg'), isFalse);
      expect(json.containsKey('notes'), isFalse);
    });
  });

  test('copyWith updates actuals but keeps identity + prescribed snapshot', () {
    final original = WorkoutLogEntryModel(
      id: 'we-1',
      exerciseId: 'ex-1',
      exerciseName: 'Squat',
      order: 1,
      sets: 4,
      reps: '5',
      weightKg: 95,
      prescribedSets: 4,
      prescribedReps: '5',
      prescribedWeightKg: 95,
    );

    final edited = original.copyWith(sets: 5);

    expect(edited.sets, 5); // actual changed
    expect(edited.exerciseId, 'ex-1'); // identity preserved
    expect(edited.order, 1);
    expect(edited.prescribedSets, 4); // snapshot preserved
    expect(edited.prescribedWeightKg, 95.0);
    // and the write shape still omits prescribed after an edit
    expect(edited.toWriteJson().containsKey('prescribedSets'), isFalse);
  });
}
