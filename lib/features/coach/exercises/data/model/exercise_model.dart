import 'exercise_enums.dart';

/// A coach's exercise library item (mirrors backend `ExerciseDto`).
class ExerciseModel {
  final String? id;
  final String? name;
  final String? description;
  final String? instructions;
  final MuscleGroup targetMuscle;
  final Equipment equipment;
  final String? videoUrl;
  final String? imageUrl;
  final bool isActive;
  final DateTime? creationTime;

  ExerciseModel({
    this.id,
    this.name,
    this.description,
    this.instructions,
    this.targetMuscle = MuscleGroup.other,
    this.equipment = Equipment.none,
    this.videoUrl,
    this.imageUrl,
    this.isActive = true,
    this.creationTime,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id']?.toString(),
      name: json['name'],
      description: json['description'],
      instructions: json['instructions'],
      targetMuscle: MuscleGroup.fromValue(json['targetMuscle']),
      equipment: Equipment.fromValue(json['equipment']),
      videoUrl: json['videoUrl'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
      creationTime: json['creationTime'] != null
          ? DateTime.tryParse(json['creationTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'instructions': instructions,
      'targetMuscle': targetMuscle.value,
      'equipment': equipment.value,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'creationTime': creationTime?.toIso8601String(),
    };
  }

  ExerciseModel copyWith({
    String? id,
    String? name,
    String? description,
    String? instructions,
    MuscleGroup? targetMuscle,
    Equipment? equipment,
    String? videoUrl,
    String? imageUrl,
    bool? isActive,
    DateTime? creationTime,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      targetMuscle: targetMuscle ?? this.targetMuscle,
      equipment: equipment ?? this.equipment,
      videoUrl: videoUrl ?? this.videoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      creationTime: creationTime ?? this.creationTime,
    );
  }
}
