import 'package:coachappmobile/core/boilerplate/pagination/models/get_list_request.dart';
import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/food_model.dart';
import '../repository/food_repository.dart';

class GetFoodListParams extends BaseParams {
  final GetListRequest? request;
  final String? filter;
  final bool? isActive;

  GetFoodListParams({this.request, this.filter, this.isActive});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (request?.skip != null) map['SkipCount'] = request!.skip;
    if (request?.take != null) map['MaxResultCount'] = request!.take;
    if (filter != null && filter!.isNotEmpty) map['Filter'] = filter;
    if (isActive != null) map['IsActive'] = isActive;
    return map;
  }
}

class GetFoodListUsecase extends UseCase<List<FoodModel>, GetFoodListParams> {
  final FoodRepository repository;

  GetFoodListUsecase(this.repository);

  @override
  Future<Result<List<FoodModel>>> call({required GetFoodListParams params}) {
    return repository.getFoodListRequest(params: params);
  }
}
