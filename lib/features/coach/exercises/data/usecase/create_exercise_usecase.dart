import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/usecase/usecase.dart';

import '../model/exercise_model.dart';
import '../repository/exercise_repository.dart';

/// Shared create/update payload (backend uses one `CreateUpdateExerciseDto`).
/// [id] is only used to target the update URL; it is not part of the body.
/// Fields are mutable for `onChanged` binding.
class SaveExerciseParams extends BaseParams {
  String id;
  String name;
  String? description;
  String? instructions;

  /// Editable Arabic instructions (coach-editable, shown to the trainee).
  String? instructionsAr;

  /// Write-once machine-translation snapshot; carried so the form can offer a
  /// "restore original translation" action and so the backend keeps preserving
  /// it across updates. Only sent when present.
  String? instructionsArOriginal;

  int targetMuscle;
  int equipment;
  String? videoUrl;
  String? imageUrl;
  bool isActive;

  SaveExerciseParams({
    this.id = '',
    this.name = '',
    this.description,
    this.instructions,
    this.instructionsAr,
    this.instructionsArOriginal,
    this.targetMuscle = 0,
    this.equipment = 0,
    this.videoUrl,
    this.imageUrl,
    this.isActive = true,
  });

  factory SaveExerciseParams.fromModel(ExerciseModel e) => SaveExerciseParams(
    id: e.id ?? '',
    name: e.name ?? '',
    description: e.description,
    instructions: e.instructions,
    instructionsAr: e.instructionsAr,
    instructionsArOriginal: e.instructionsArOriginal,
    targetMuscle: e.targetMuscle.value,
    equipment: e.equipment.value,
    videoUrl: e.videoUrl,
    imageUrl: e.imageUrl,
    isActive: e.isActive,
  );

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (instructions != null && instructions!.isNotEmpty)
        'instructions': instructions,
      // Always send the Arabic instructions (null when empty) so a coach can
      // clear them, mirroring how `instructions` is treated as optional text.
      'instructionsAr': (instructionsAr != null && instructionsAr!.isNotEmpty)
          ? instructionsAr
          : null,
      if (instructionsArOriginal != null && instructionsArOriginal!.isNotEmpty)
        'instructionsArOriginal': instructionsArOriginal,
      'targetMuscle': targetMuscle,
      'equipment': equipment,
      if (videoUrl != null && videoUrl!.isNotEmpty) 'videoUrl': videoUrl,
      if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }
}

class CreateExerciseUsecase extends UseCase<ExerciseModel, SaveExerciseParams> {
  final ExerciseRepository repository;

  CreateExerciseUsecase(this.repository);

  @override
  Future<Result<ExerciseModel>> call({required SaveExerciseParams params}) {
    return repository.createExerciseRequest(params: params);
  }
}
