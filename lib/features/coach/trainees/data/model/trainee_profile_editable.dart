/// The set of trainee profile fields common to create and update. Implemented
/// by both `CreateTraineeParams` and `UpdateTraineeParams` so a single form
/// widget can bind to either without duplication. `gender`/`goal` are the
/// integer enum wire values.
abstract class TraineeProfileEditable {
  String get firstName;
  set firstName(String value);

  String get lastName;
  set lastName(String value);

  String? get email;
  set email(String? value);

  String? get phoneNumber;
  set phoneNumber(String? value);

  int get gender;
  set gender(int value);

  DateTime? get birthDate;
  set birthDate(DateTime? value);

  int get goal;
  set goal(int value);

  double? get heightCm;
  set heightCm(double? value);

  double? get startWeightKg;
  set startWeightKg(double? value);

  double? get targetWeightKg;
  set targetWeightKg(double? value);

  bool get isActive;
  set isActive(bool value);
}
