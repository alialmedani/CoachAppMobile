import 'package:coachappmobile/core/params/base_params.dart';

import '../model/trainee_note_model.dart';

/// Create/update body for a trainee note (`CreateUpdateTraineeNoteDto`).
/// `traineeId`, `date`, and `text` (max 2000) are all required. [id] targets
/// the update URL only.
class CreateUpdateTraineeNoteParams extends BaseParams {
  String id;
  String traineeId;
  String date; // ISO-8601
  String text;

  CreateUpdateTraineeNoteParams({
    this.id = '',
    this.traineeId = '',
    this.date = '',
    this.text = '',
  });

  factory CreateUpdateTraineeNoteParams.fromModel(TraineeNoteModel m) {
    return CreateUpdateTraineeNoteParams(
      id: m.id ?? '',
      traineeId: m.traineeId ?? '',
      date: (m.date ?? DateTime.now()).toIso8601String(),
      text: m.text,
    );
  }

  Map<String, dynamic> toJson() => {
    'traineeId': traineeId,
    'date': date,
    'text': text.trim(),
  };
}
