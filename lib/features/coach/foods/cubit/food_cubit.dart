import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:meta/meta.dart';

import '../data/model/food_model.dart';
import '../data/repository/food_repository.dart';
import '../data/usecase/create_food_usecase.dart';
import '../data/usecase/delete_food_usecase.dart';
import '../data/usecase/get_food_list_usecase.dart';
import '../data/usecase/get_food_usecase.dart';
import '../data/usecase/update_food_usecase.dart';

part 'food_state.dart';

/// Orchestrates the coach food library. API methods return `Future<Result>`;
/// only the search setter emits.
class FoodCubit extends Cubit<FoodState> {
  FoodCubit() : super(FoodInitial());

  final FoodRepository _repository = FoodRepository();

  SaveFoodParams saveParams = SaveFoodParams();

  String searchTerm = '';

  void setSearchTerm(String value) {
    searchTerm = value;
    emit(FoodSearchChanged());
  }

  Future<Result> fetchFoodList(dynamic data) async {
    return await GetFoodListUsecase(_repository).call(
      params: GetFoodListParams(
        request: data,
        filter: searchTerm.isNotEmpty ? searchTerm : null,
      ),
    );
  }

  Future<Result> fetchFoodById(String id) async {
    return await GetFoodUsecase(_repository).call(params: GetFoodParams(id: id));
  }

  Future<Result> createFood() async {
    return await CreateFoodUsecase(_repository).call(params: saveParams);
  }

  Future<Result> updateFood() async {
    return await UpdateFoodUsecase(_repository).call(params: saveParams);
  }

  Future<Result> deleteFood(String id) async {
    return await DeleteFoodUsecase(_repository).call(
      params: DeleteFoodParams(id: id),
    );
  }

  void prepareCreate() => saveParams = SaveFoodParams();

  void prepareEdit(FoodModel food) => saveParams = SaveFoodParams.fromModel(food);
}
