import 'package:coachappmobile/core/params/base_params.dart';

/// Request shape for `GET /api/app/my-exercise/{id}` — carries the exercise id
/// the trainee tapped in their workout plan. The id travels in the path, so
/// [toJson] stays empty (no query/body payload for this read).
class GetMyExerciseParams extends BaseParams {
  final String id;

  GetMyExerciseParams({required this.id});

  Map<String, dynamic> toJson() => {};
}
