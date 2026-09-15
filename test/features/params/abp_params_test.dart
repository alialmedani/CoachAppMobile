import 'package:coachappmobile/core/boilerplate/pagination/models/get_list_request.dart';
import 'package:coachappmobile/features/coach/exercises/data/usecase/create_exercise_usecase.dart';
import 'package:coachappmobile/features/coach/foods/data/usecase/create_food_usecase.dart';
import 'package:coachappmobile/features/coach/tracking/data/params/progress_entry_params.dart';
import 'package:coachappmobile/features/coach/tracking/data/params/tracking_list_input.dart';
import 'package:coachappmobile/features/coach/trainees/data/usecase/get_trainee_list_usecase.dart';
import 'package:coachappmobile/features/trainee/my_progress/data/params/create_my_progress_params.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contract tests for the request params — the shapes the backend actually
/// receives. These lock the ABP param names and the per-endpoint conventions
/// (Filter vs SearchTerm, id-in-URL-not-body, traineeId omitted on self-scoped
/// endpoints).
void main() {
  group('GetTraineeListParams (coach list uses Filter)', () {
    test('maps to SkipCount/MaxResultCount/Filter/Goal/IsActive', () {
      final json = GetTraineeListParams(
        request: GetListRequest(skip: 0, take: 25),
        filter: 'ali',
        goal: 2,
        isActive: true,
      ).toJson();

      expect(json['SkipCount'], 0);
      expect(json['MaxResultCount'], 25);
      expect(json['Filter'], 'ali');
      expect(json['Goal'], 2);
      expect(json['IsActive'], true);
      // coach trainee list filters via `Filter`, not `SearchTerm`
      expect(json.containsKey('SearchTerm'), isFalse);
    });

    test('omits empty filter and null facets', () {
      final json = GetTraineeListParams(
        request: GetListRequest(skip: 0, take: 25),
        filter: '',
      ).toJson();
      expect(json.containsKey('Filter'), isFalse);
      expect(json.containsKey('Goal'), isFalse);
      expect(json.containsKey('IsActive'), isFalse);
    });
  });

  group('TrackingListInput (date-ranged, no Filter/SearchTerm)', () {
    test('maps to SkipCount/MaxResultCount/TraineeId/FromDate/ToDate/Sorting', () {
      final json = TrackingListInput(
        request: GetListRequest(skip: 0, take: 50),
        traineeId: 't-1',
        fromDate: '2026-08-17',
        toDate: '2026-09-13',
        sorting: 'Date desc',
      ).toJson();

      expect(json['SkipCount'], 0);
      expect(json['MaxResultCount'], 50);
      expect(json['TraineeId'], 't-1');
      expect(json['FromDate'], '2026-08-17');
      expect(json['ToDate'], '2026-09-13');
      expect(json['Sorting'], 'Date desc');
      // tracking endpoints have no free-text search / Filter
      expect(json.containsKey('Filter'), isFalse);
      expect(json.containsKey('SearchTerm'), isFalse);
    });

    test('omits an empty traineeId and empty dates', () {
      final json = TrackingListInput(traineeId: '').toJson();
      expect(json.containsKey('TraineeId'), isFalse);
      expect(json.containsKey('FromDate'), isFalse);
      expect(json.containsKey('ToDate'), isFalse);
    });
  });

  group('SaveFoodParams body', () {
    test('emits the nutrition body without the URL id', () {
      final json = SaveFoodParams(
        id: 'f-1',
        name: 'Oats',
        servingSize: 40,
        servingUnit: 'g',
        calories: 150,
        proteinG: 5,
        carbsG: 27,
        fatG: 3,
        isActive: true,
      ).toJson();

      expect(json['name'], 'Oats');
      expect(json['servingSize'], 40.0);
      expect(json['calories'], 150.0);
      expect(json['isActive'], true);
      // id targets the update URL, never the body
      expect(json.containsKey('id'), isFalse);
    });

    test('omits an empty optional description', () {
      final withDesc = SaveFoodParams(name: 'x', description: 'note').toJson();
      final noDesc = SaveFoodParams(name: 'x', description: '').toJson();
      expect(withDesc['description'], 'note');
      expect(noDesc.containsKey('description'), isFalse);
    });
  });

  group('SaveExerciseParams body', () {
    test('emits enum ints and omits the URL id + empty optionals', () {
      final json = SaveExerciseParams(
        id: 'e-1',
        name: 'Squat',
        targetMuscle: 5,
        equipment: 2,
      ).toJson();

      expect(json['name'], 'Squat');
      expect(json['targetMuscle'], 5);
      expect(json['equipment'], 2);
      expect(json['isActive'], true);
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('description'), isFalse);
      expect(json.containsKey('videoUrl'), isFalse);
    });
  });

  group('progress params — traineeId scoping', () {
    test('coach CreateUpdateProgressEntryParams INCLUDES traineeId', () {
      final json = CreateUpdateProgressEntryParams(
        id: 'p-1',
        traineeId: 't-1',
        date: '2026-09-13T00:00:00',
        weightKg: 81.5,
        bodyFatPercent: 18.2,
      ).toJson();

      expect(json['traineeId'], 't-1');
      expect(json['date'], '2026-09-13T00:00:00');
      expect(json['weightKg'], 81.5);
      expect(json['bodyFatPercent'], 18.2);
      // id targets the URL, not the body
      expect(json.containsKey('id'), isFalse);
      // absent measures are omitted
      expect(json.containsKey('chestCm'), isFalse);
    });

    test('trainee CreateMyProgressParams OMITS traineeId (server derives it)', () {
      final json = CreateMyProgressParams(
        date: '2026-09-13T00:00:00',
        weightKg: 82.4,
      ).toJson();

      expect(json['date'], '2026-09-13T00:00:00');
      expect(json['weightKg'], 82.4);
      // self-scoped endpoint: caller identity comes from the token
      expect(json.containsKey('traineeId'), isFalse);
    });
  });
}
