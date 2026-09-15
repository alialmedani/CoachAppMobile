import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/trainee/shared/trainee_params.dart';

import '../data/params/update_my_profile_params.dart';
import '../data/repository/my_profile_repository.dart';
import '../data/usecase/my_profile_usecase.dart';

part 'my_profile_state.dart';

/// Orchestrates the trainee's own profile (read + restricted contact-details
/// self-edit). Boilerplate widgets own the async UI state; no `emit` for API.
class MyProfileCubit extends Cubit<MyProfileState> {
  MyProfileCubit() : super(MyProfileInitial());

  final MyProfileRepository _repository = MyProfileRepository();

  /// Mutable params for the self-edit form (phone/email/birth date only).
  UpdateMyProfileParams editParams = UpdateMyProfileParams();

  Future<Result> fetchProfile() =>
      GetMyProfileUsecase(_repository).call(params: NoParams());

  Future<Result> updateProfile() =>
      UpdateMyProfileUsecase(_repository).call(params: editParams);
}
