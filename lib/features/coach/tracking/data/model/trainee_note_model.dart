/// A coach-authored note about a trainee (mirrors backend `TraineeNoteDto`).
class TraineeNoteModel {
  final String? id;
  final String? traineeId;
  final DateTime? date;
  final String text;

  TraineeNoteModel({this.id, this.traineeId, this.date, this.text = ''});

  factory TraineeNoteModel.fromJson(Map<String, dynamic> json) {
    return TraineeNoteModel(
      id: json['id']?.toString(),
      traineeId: json['traineeId']?.toString(),
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      text: json['text'] ?? '',
    );
  }
}
