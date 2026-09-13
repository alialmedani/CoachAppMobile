import 'trainee_enums.dart';

/// A coach-managed trainee (mirrors the backend `TraineeDto`).
///
/// JSON is camelCase; enums (`gender`, `goal`) are integers; audit fields come
/// from ABP's `FullAuditedEntityDto<Guid>`.
class TraineeModel {
  final String? id;
  final String? userId;
  final String? userName;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final Gender gender;
  final DateTime? birthDate;
  final TrainingGoal goal;
  final double? heightCm;
  final double? startWeightKg;
  final double? targetWeightKg;
  final bool isActive;
  final DateTime? creationTime;

  TraineeModel({
    this.id,
    this.userId,
    this.userName,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.gender = Gender.unspecified,
    this.birthDate,
    this.goal = TrainingGoal.general,
    this.heightCm,
    this.startWeightKg,
    this.targetWeightKg,
    this.isActive = true,
    this.creationTime,
  });

  /// Full display name, falling back to the user name when a part is missing.
  String get fullName {
    final parts = [firstName, lastName]
        .whereType<String>()
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return userName ?? '';
    return parts.join(' ');
  }

  /// First letter for an avatar fallback.
  String get initial {
    final source = fullName.trim().isNotEmpty ? fullName.trim() : (userName ?? '');
    return source.isEmpty ? '?' : source.substring(0, 1).toUpperCase();
  }

  factory TraineeModel.fromJson(Map<String, dynamic> json) {
    return TraineeModel(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      userName: json['userName'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      gender: Gender.fromValue(json['gender']),
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'])
          : null,
      goal: TrainingGoal.fromValue(json['goal']),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      startWeightKg: (json['startWeightKg'] as num?)?.toDouble(),
      targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble(),
      isActive: json['isActive'] ?? true,
      creationTime: json['creationTime'] != null
          ? DateTime.tryParse(json['creationTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'gender': gender.value,
      'birthDate': birthDate?.toIso8601String(),
      'goal': goal.value,
      'heightCm': heightCm,
      'startWeightKg': startWeightKg,
      'targetWeightKg': targetWeightKg,
      'isActive': isActive,
      'creationTime': creationTime?.toIso8601String(),
    };
  }

  TraineeModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    Gender? gender,
    DateTime? birthDate,
    TrainingGoal? goal,
    double? heightCm,
    double? startWeightKg,
    double? targetWeightKg,
    bool? isActive,
    DateTime? creationTime,
  }) {
    return TraineeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      goal: goal ?? this.goal,
      heightCm: heightCm ?? this.heightCm,
      startWeightKg: startWeightKg ?? this.startWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      isActive: isActive ?? this.isActive,
      creationTime: creationTime ?? this.creationTime,
    );
  }
}
