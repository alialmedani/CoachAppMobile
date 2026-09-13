import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/food_model.dart';
import '../repository/food_repository.dart';

class GetFoodParams extends BaseParams {
  final String id;

  GetFoodParams({required this.id});

  Map<String, dynamic> toJson() => <String, dynamic>{};
}

class GetFoodUsecase extends UseCase<FoodModel, GetFoodParams> {
  final FoodRepository repository;

  GetFoodUsecase(this.repository);

  @override
  Future<Result<FoodModel>> call({required GetFoodParams params}) {
    return repository.getFoodByIdRequest(id: params.id);
  }
}
