import 'package:coachappmobile/features/coach/tracking/data/model/nutrition_adherence_range_model.dart';
import 'package:coachappmobile/features/coach/tracking/data/model/progress_entry_model.dart';
import 'package:coachappmobile/features/coach/tracking/data/model/trainee_dashboard_model.dart';
import 'package:coachappmobile/features/coach/tracking/data/model/workout_completion_model.dart';
import 'package:coachappmobile/features/trainee/today/data/model/nutrition_adherence_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for the read-only tracking DTOs: [ProgressEntryModel] (parse-only,
/// singular `bodyFatPercent`/`armCm`), and the composed [TraineeDashboardModel]
/// (nested nutrition adherence + workout completion, both nullable).
void main() {
  group('ProgressEntryModel.fromJson', () {
    test('parses all optional decimal measures', () {
      final m = ProgressEntryModel.fromJson({
        'id': 'p-1',
        'traineeId': 't-1',
        'date': '2026-09-08T00:00:00',
        'weightKg': 81.5,
        'bodyFatPercent': 18.2,
        'chestCm': 100,
        'waistCm': 85,
        'hipsCm': 95,
        'armCm': 38,
        'thighCm': 55,
        'notes': 'baseline',
      });

      expect(m.id, 'p-1');
      expect(m.traineeId, 't-1');
      expect(m.date, DateTime.parse('2026-09-08T00:00:00'));
      expect(m.weightKg, 81.5);
      expect(m.bodyFatPercent, 18.2);
      expect(m.chestCm, 100.0);
      expect(m.armCm, 38.0); // singular field name
      expect(m.thighCm, 55.0);
      expect(m.notes, 'baseline');
    });

    test('leaves absent measures null (partial entry)', () {
      final m = ProgressEntryModel.fromJson({
        'id': 'p-2',
        'date': '2026-09-10T00:00:00',
        'weightKg': 80,
      });
      expect(m.weightKg, 80.0);
      expect(m.bodyFatPercent, isNull);
      expect(m.chestCm, isNull);
      expect(m.notes, isNull);
    });

    test('handles a null date', () {
      final m = ProgressEntryModel.fromJson({'id': 'p-3'});
      expect(m.date, isNull);
    });
  });

  group('TraineeDashboardModel.fromJson', () {
    test('parses the composed adherence + completion sub-objects', () {
      final m = TraineeDashboardModel.fromJson({
        'traineeId': 't-1',
        'nutritionAdherence': {
          'hasActivePlan': true,
          'hasLog': true,
          'consumedCalories': 1800,
          'targetCalories': 2000,
          'caloriesPercent': 90,
        },
        'workoutCompletion': {
          'hasActivePlan': true,
          'weeks': 4,
          'plannedSessions': 12,
          'completedSessions': 9,
          'completionPercent': 75,
        },
      });

      expect(m.traineeId, 't-1');
      expect(m.nutritionAdherence, isA<NutritionAdherenceModel>());
      expect(m.nutritionAdherence!.hasActivePlan, isTrue);
      expect(m.nutritionAdherence!.consumedCalories, 1800.0);
      expect(m.nutritionAdherence!.targetCalories, 2000.0);
      expect(m.nutritionAdherence!.caloriesPercent, 90.0);

      expect(m.workoutCompletion, isA<WorkoutCompletionModel>());
      expect(m.workoutCompletion!.weeks, 4);
      expect(m.workoutCompletion!.plannedSessions, 12);
      expect(m.workoutCompletion!.completedSessions, 9);
      expect(m.workoutCompletion!.completionPercent, 75.0);
    });

    test('tolerates missing sub-objects (no active plan/log)', () {
      final m = TraineeDashboardModel.fromJson({'traineeId': 't-2'});
      expect(m.nutritionAdherence, isNull);
      expect(m.nutritionAdherenceRange, isNull);
      expect(m.workoutCompletion, isNull);
    });

    test('parses the F5/PD5 nutrition adherence range sub-object', () {
      final m = TraineeDashboardModel.fromJson({
        'traineeId': 't-1',
        'nutritionAdherenceRange': {
          'fromDate': '2026-09-08T00:00:00',
          'toDate': '2026-09-14T00:00:00',
          'daysInRange': 7,
          'daysLogged': 5,
          'hasActivePlan': true,
          'consumedCaloriesTotal': 9500,
          'targetCaloriesPerDay': 2000,
          'averageCaloriesPercent': 95.0,
        },
      });

      final r = m.nutritionAdherenceRange;
      expect(r, isA<NutritionAdherenceRangeModel>());
      expect(r!.daysInRange, 7);
      expect(r.daysLogged, 5);
      expect(r.hasActivePlan, isTrue);
      expect(r.consumedCaloriesTotal, 9500.0);
      expect(r.targetCaloriesPerDay, 2000.0);
      expect(r.averageCaloriesPercent, 95.0);
    });
  });

  group('NutritionAdherenceRangeModel.fromJson', () {
    test('defaults counts to 0 and nullable percents/target to null', () {
      final r = NutritionAdherenceRangeModel.fromJson({'hasActivePlan': true});
      expect(r.daysInRange, 0);
      expect(r.daysLogged, 0);
      expect(r.hasActivePlan, isTrue);
      expect(r.consumedCaloriesTotal, 0.0);
      expect(r.targetCaloriesPerDay, isNull);
      expect(r.averageCaloriesPercent, isNull);
    });
  });

  group('sub-model defaults', () {
    test('NutritionAdherenceModel defaults consumed to 0 and targets to null', () {
      final a = NutritionAdherenceModel.fromJson({'hasActivePlan': false});
      expect(a.consumedCalories, 0.0);
      expect(a.consumedProteinG, 0.0);
      expect(a.targetCalories, isNull);
      expect(a.overallPercent, isNull);
      expect(a.hasActivePlan, isFalse);
      expect(a.hasLog, isFalse);
    });

    test('WorkoutCompletionModel defaults weeks to 1 and completed to 0', () {
      final c = WorkoutCompletionModel.fromJson({'hasActivePlan': false});
      expect(c.weeks, 1);
      expect(c.completedSessions, 0);
      expect(c.plannedSessions, isNull);
      expect(c.completionPercent, isNull);
    });
  });
}
