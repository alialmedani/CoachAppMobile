import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';

import '../model/food_model.dart';
import '../usecase/create_food_usecase.dart';
import '../usecase/get_food_list_usecase.dart';

class FoodRepository extends CoreRepository {
  Future<Result<List<FoodModel>>> getFoodListRequest({
    required GetFoodListParams params,
  }) async {
    final result = await RemoteDataSource.request<List<FoodModel>>(
      withAuthentication: true,
      url: foodUrl,
      method: HttpMethod.GET,
      queryParameters: params.toJson(),
      converter: (json) {
        final List<dynamic> data = json['items'] ?? json['data'] ?? [];
        return data.map((e) => FoodModel.fromJson(e)).toList();
      },
    );
    return paginatedCall(result: result);
  }

  Future<Result<FoodModel>> getFoodByIdRequest({required String id}) async {
    final result = await RemoteDataSource.request<FoodModel>(
      withAuthentication: true,
      url: '$foodUrl/$id',
      method: HttpMethod.GET,
      converter: (json) => FoodModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<FoodModel>> createFoodRequest({
    required SaveFoodParams params,
  }) async {
    final result = await RemoteDataSource.request<FoodModel>(
      withAuthentication: true,
      url: foodUrl,
      method: HttpMethod.POST,
      data: params.toJson(),
      converter: (json) => FoodModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<FoodModel>> updateFoodRequest({
    required String id,
    required SaveFoodParams params,
  }) async {
    final result = await RemoteDataSource.request<FoodModel>(
      withAuthentication: true,
      url: '$foodUrl/$id',
      method: HttpMethod.PUT,
      data: params.toJson(),
      converter: (json) => FoodModel.fromJson(json),
    );
    return call(result: result);
  }

  Future<Result<String>> deleteFoodRequest({required String id}) async {
    final result = await RemoteDataSource.noModelRequest(
      withAuthentication: true,
      url: '$foodUrl/$id',
      method: HttpMethod.DELETE,
    );
    return noModelCall(result: result);
  }
}
