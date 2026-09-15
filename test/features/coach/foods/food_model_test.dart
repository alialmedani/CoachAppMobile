import 'package:coachappmobile/features/coach/foods/data/model/food_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for [FoodModel] — mirrors the backend `FoodDto`.
/// Covers fromJson parsing (incl. int-vs-double numbers), toJson shape,
/// round-trip stability, defaults on missing keys, and copyWith.
void main() {
  group('FoodModel.fromJson', () {
    test('parses a full backend payload', () {
      final model = FoodModel.fromJson({
        'id': 'f-1',
        'name': 'Chicken Breast',
        'description': 'Skinless',
        'servingSize': 100,
        'servingUnit': 'g',
        'calories': 165,
        'proteinG': 31,
        'carbsG': 0,
        'fatG': 3.6,
        'isActive': true,
        'creationTime': '2026-09-08T10:00:00',
      });

      expect(model.id, 'f-1');
      expect(model.name, 'Chicken Breast');
      expect(model.description, 'Skinless');
      expect(model.servingSize, 100.0);
      expect(model.servingUnit, 'g');
      expect(model.calories, 165.0);
      expect(model.proteinG, 31.0);
      expect(model.carbsG, 0.0);
      expect(model.fatG, 3.6);
      expect(model.isActive, isTrue);
      expect(model.creationTime, DateTime.parse('2026-09-08T10:00:00'));
    });

    test('coerces integer JSON numbers to double', () {
      final model = FoodModel.fromJson({'name': 'Rice', 'calories': 130});
      expect(model.calories, isA<double>());
      expect(model.calories, 130.0);
    });

    test('applies defaults for missing/null fields', () {
      final model = FoodModel.fromJson({'name': 'Empty'});
      expect(model.servingSize, 100.0);
      expect(model.servingUnit, 'g');
      expect(model.calories, 0.0);
      expect(model.isActive, isTrue);
      expect(model.creationTime, isNull);
      expect(model.description, isNull);
    });

    test('stringifies a non-string id', () {
      final model = FoodModel.fromJson({'id': 42, 'name': 'x'});
      expect(model.id, '42');
    });
  });

  group('FoodModel.toJson', () {
    test('emits every camelCase key', () {
      final json = FoodModel(
        id: 'f-2',
        name: 'Oats',
        servingSize: 40,
        servingUnit: 'g',
        calories: 150,
        proteinG: 5,
        carbsG: 27,
        fatG: 3,
        isActive: false,
      ).toJson();

      expect(json['id'], 'f-2');
      expect(json['name'], 'Oats');
      expect(json['servingSize'], 40.0);
      expect(json['servingUnit'], 'g');
      expect(json['calories'], 150.0);
      expect(json['proteinG'], 5.0);
      expect(json['carbsG'], 27.0);
      expect(json['fatG'], 3.0);
      expect(json['isActive'], isFalse);
      expect(json.containsKey('creationTime'), isTrue);
    });
  });

  test('round-trips fromJson -> toJson -> fromJson', () {
    final original = FoodModel(
      id: 'f-3',
      name: 'Salmon',
      description: 'Wild',
      servingSize: 120,
      servingUnit: 'g',
      calories: 208,
      proteinG: 20,
      carbsG: 0,
      fatG: 13,
      isActive: true,
    );

    final restored = FoodModel.fromJson(original.toJson());

    expect(restored.id, original.id);
    expect(restored.name, original.name);
    expect(restored.description, original.description);
    expect(restored.servingSize, original.servingSize);
    expect(restored.servingUnit, original.servingUnit);
    expect(restored.calories, original.calories);
    expect(restored.proteinG, original.proteinG);
    expect(restored.carbsG, original.carbsG);
    expect(restored.fatG, original.fatG);
    expect(restored.isActive, original.isActive);
  });

  test('copyWith overrides only the given field', () {
    final base = FoodModel(id: 'f-4', name: 'Base', calories: 100);
    final copy = base.copyWith(calories: 250);

    expect(copy.id, 'f-4');
    expect(copy.name, 'Base');
    expect(copy.calories, 250.0);
    // original untouched
    expect(base.calories, 100.0);
  });
}
