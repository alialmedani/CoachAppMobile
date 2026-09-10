import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../results/result.dart';

part 'get_model_state.dart';

typedef UsecaseCallBack = Future<Result> Function(); //dynamic data:params

class GetModelCubit<Model> extends Cubit<GetModelState> {
  final UsecaseCallBack getData;
  GetModelCubit(this.getData) : super(GetModelInitial());

  Future<void> getModel() async {
    emit(Loading());
    Result response;
    try {
      response =
          await getData(); // response = await GetExampleUseCase(ExampleRepository()).call(params: params);
      if (response.hasDataOnly) {
        emit(GetModelSuccessfully(model: response.data));
      } else if (response.hasErrorOnly) {
        emit(Error(message: response.error ?? ''));
      } else {
        emit(Error(message: 'some thing went wrong'));
      }
    } catch (e) {
      emit(Error(message: 'some thing went wrong $e'));
    }
  }
}
