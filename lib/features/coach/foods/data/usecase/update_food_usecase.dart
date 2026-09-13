import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/food_model.dart';
import '../repository/food_repository.dart';
import 'create_food_usecase.dart';

class UpdateFoodUsecase extends UseCase<FoodModel, SaveFoodParams> {
  final FoodRepository repository;

  UpdateFoodUsecase(this.repository);

  @override
  Future<Result<FoodModel>> call({required SaveFoodParams params}) {
    return repository.updateFoodRequest(id: params.id, params: params);
  }
}
