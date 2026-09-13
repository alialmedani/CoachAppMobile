import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/trainee_enums.dart';
import '../model/trainee_model.dart';
import '../model/trainee_profile_editable.dart';
import '../repository/trainee_repository.dart';

/// Create a trainee login + profile (ABP `CreateTraineeDto`).
/// Fields are mutable so the create form can bind them via `onChanged`.
class CreateTraineeParams extends BaseParams implements TraineeProfileEditable {
  String userName;
  String password;
  @override
  String firstName;
  @override
  String lastName;
  @override
  String? email;
  @override
  String? phoneNumber;
  @override
  int gender;
  @override
  DateTime? birthDate;
  @override
  int goal;
  @override
  double? heightCm;
  @override
  double? startWeightKg;
  @override
  double? targetWeightKg;
  @override
  bool isActive;

  CreateTraineeParams({
    this.userName = '',
    this.password = '',
    this.firstName = '',
    this.lastName = '',
    this.email,
    this.phoneNumber,
    this.gender = 0,
    this.birthDate,
    this.goal = 0,
    this.heightCm,
    this.startWeightKg,
    this.targetWeightKg,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (phoneNumber != null && phoneNumber!.isNotEmpty)
        'phoneNumber': phoneNumber,
      'gender': gender,
      if (birthDate != null) 'birthDate': birthDate!.toIso8601String(),
      'goal': goal,
      if (heightCm != null) 'heightCm': heightCm,
      if (startWeightKg != null) 'startWeightKg': startWeightKg,
      if (targetWeightKg != null) 'targetWeightKg': targetWeightKg,
      'isActive': isActive,
    };
  }

  /// Reset to blank defaults (called after a successful create).
  void reset() {
    userName = '';
    password = '';
    firstName = '';
    lastName = '';
    email = null;
    phoneNumber = null;
    gender = Gender.unspecified.value;
    birthDate = null;
    goal = TrainingGoal.general.value;
    heightCm = null;
    startWeightKg = null;
    targetWeightKg = null;
    isActive = true;
  }
}

class CreateTraineeUsecase extends UseCase<TraineeModel, CreateTraineeParams> {
  final TraineeRepository repository;

  CreateTraineeUsecase(this.repository);

  @override
  Future<Result<TraineeModel>> call({required CreateTraineeParams params}) {
    return repository.createTraineeRequest(params: params);
  }
}
