import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../repository/food_repository.dart';

class DeleteFoodParams extends BaseParams {
  final String id;

  DeleteFoodParams({required this.id});

  Map<String, dynamic> toJson() => <String, dynamic>{};
}

class DeleteFoodUsecase extends UseCase<String, DeleteFoodParams> {
  final FoodRepository repository;

  DeleteFoodUsecase(this.repository);

  @override
  Future<Result<String>> call({required DeleteFoodParams params}) {
    return repository.deleteFoodRequest(id: params.id);
  }
}
