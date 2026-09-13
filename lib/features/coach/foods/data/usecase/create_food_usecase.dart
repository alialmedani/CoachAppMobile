import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/food_model.dart';
import '../repository/food_repository.dart';

/// Shared create/update payload (backend uses one `CreateUpdateFoodDto`).
/// [id] only targets the update URL; it is not part of the body.
class SaveFoodParams extends BaseParams {
  String id;
  String name;
  String? description;
  double servingSize;
  String servingUnit;
  double calories;
  double proteinG;
  double carbsG;
  double fatG;
  bool isActive;

  SaveFoodParams({
    this.id = '',
    this.name = '',
    this.description,
    this.servingSize = 100,
    this.servingUnit = 'g',
    this.calories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
    this.isActive = true,
  });

  factory SaveFoodParams.fromModel(FoodModel f) => SaveFoodParams(
    id: f.id ?? '',
    name: f.name ?? '',
    description: f.description,
    servingSize: f.servingSize,
    servingUnit: f.servingUnit,
    calories: f.calories,
    proteinG: f.proteinG,
    carbsG: f.carbsG,
    fatG: f.fatG,
    isActive: f.isActive,
  );

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null && description!.isNotEmpty)
        'description': description,
      'servingSize': servingSize,
      'servingUnit': servingUnit,
      'calories': calories,
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatG': fatG,
      'isActive': isActive,
    };
  }
}

class CreateFoodUsecase extends UseCase<FoodModel, SaveFoodParams> {
  final FoodRepository repository;

  CreateFoodUsecase(this.repository);

  @override
  Future<Result<FoodModel>> call({required SaveFoodParams params}) {
    return repository.createFoodRequest(params: params);
  }
}
