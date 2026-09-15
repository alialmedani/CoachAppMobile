import 'package:bloc_test/bloc_test.dart';
import 'package:coachappmobile/features/coach/foods/cubit/food_cubit.dart';
import 'package:coachappmobile/features/coach/foods/data/model/food_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cubit orchestration tests for [FoodCubit].
///
/// The feature cubits construct their repository internally (no DI seam), so the
/// network methods can't be faked here — these tests cover the **no-network**
/// orchestration the cubit owns: the search-emit exception and the
/// prepareCreate/prepareEdit param population that the save screens depend on.
void main() {
  group('setSearchTerm', () {
    blocTest<FoodCubit, FoodState>(
      'emits FoodSearchChanged and stores the term',
      build: FoodCubit.new,
      act: (cubit) => cubit.setSearchTerm('chicken'),
      expect: () => [isA<FoodSearchChanged>()],
      verify: (cubit) => expect(cubit.searchTerm, 'chicken'),
    );

    blocTest<FoodCubit, FoodState>(
      'emits once per search change',
      build: FoodCubit.new,
      act: (cubit) {
        cubit.setSearchTerm('a');
        cubit.setSearchTerm('ab');
      },
      expect: () => [isA<FoodSearchChanged>(), isA<FoodSearchChanged>()],
      verify: (cubit) => expect(cubit.searchTerm, 'ab'),
    );
  });

  group('prepareCreate / prepareEdit', () {
    late FoodCubit cubit;

    setUp(() => cubit = FoodCubit());
    tearDown(() => cubit.close());

    test('prepareCreate resets saveParams to defaults', () {
      cubit.prepareCreate();
      expect(cubit.saveParams.id, '');
      expect(cubit.saveParams.name, '');
      expect(cubit.saveParams.servingSize, 100);
      expect(cubit.saveParams.servingUnit, 'g');
      expect(cubit.saveParams.calories, 0);
      expect(cubit.saveParams.isActive, isTrue);
    });

    test('prepareEdit populates saveParams from the model', () {
      cubit.prepareEdit(
        FoodModel(
          id: 'f-1',
          name: 'Oats',
          description: 'rolled',
          servingSize: 40,
          servingUnit: 'g',
          calories: 150,
          proteinG: 5,
          carbsG: 27,
          fatG: 3,
          isActive: false,
        ),
      );

      expect(cubit.saveParams.id, 'f-1');
      expect(cubit.saveParams.name, 'Oats');
      expect(cubit.saveParams.description, 'rolled');
      expect(cubit.saveParams.servingSize, 40);
      expect(cubit.saveParams.calories, 150);
      expect(cubit.saveParams.proteinG, 5);
      expect(cubit.saveParams.isActive, isFalse);
    });

    test('prepareCreate after prepareEdit clears the previous draft', () {
      cubit.prepareEdit(FoodModel(id: 'f-2', name: 'Rice'));
      cubit.prepareCreate();
      expect(cubit.saveParams.id, '');
      expect(cubit.saveParams.name, '');
    });
  });
}
