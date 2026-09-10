import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../results/result.dart';
part 'create_model_state.dart';

typedef UsecaseCallBack = Future<Result>? Function(dynamic data);

class CreateModelCubit<Model> extends Cubit<CreateModelState> {
  final UsecaseCallBack getData;
  CreateModelCubit(this.getData) : super(CreateModelInitial());
  Future<void> createModel({dynamic requestData}) async {
    emit(Loading());
    try {
      Result? response = await getData(requestData);
      if (response != null) {
        if (response.hasDataOnly) {
          emit(CreateModelSuccessfully(model: response.data));
        } else if (response.hasErrorOnly) {
          emit(Error(message: response.error ?? '', error: response.error));
        } else {
          emit(Error(message: 'some thing went wrong'));
        }
      } else {
        emit(CreateModelInitial());
      }
    } catch (e) {
      emit(Error(message: e.toString()));
    }
  }
}
