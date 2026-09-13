import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/trainee_model.dart';
import '../model/trainee_profile_editable.dart';
import '../repository/trainee_repository.dart';

/// Editable trainee profile fields (ABP `UpdateTraineeDto`). Login credentials
/// are not changed here. Fields are mutable for `onChanged` binding.
class UpdateTraineeParams extends BaseParams implements TraineeProfileEditable {
  String id;
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

  UpdateTraineeParams({
    this.id = '',
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

  /// Seed the params from an existing trainee for editing.
  factory UpdateTraineeParams.fromModel(TraineeModel t) => UpdateTraineeParams(
    id: t.id ?? '',
    firstName: t.firstName ?? '',
    lastName: t.lastName ?? '',
    email: t.email,
    phoneNumber: t.phoneNumber,
    gender: t.gender.value,
    birthDate: t.birthDate,
    goal: t.goal.value,
    heightCm: t.heightCm,
    startWeightKg: t.startWeightKg,
    targetWeightKg: t.targetWeightKg,
    isActive: t.isActive,
  );

  Map<String, dynamic> toJson() {
    return {
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
}

class UpdateTraineeUsecase extends UseCase<TraineeModel, UpdateTraineeParams> {
  final TraineeRepository repository;

  UpdateTraineeUsecase(this.repository);

  @override
  Future<Result<TraineeModel>> call({required UpdateTraineeParams params}) {
    return repository.updateTraineeRequest(id: params.id, params: params);
  }
}
