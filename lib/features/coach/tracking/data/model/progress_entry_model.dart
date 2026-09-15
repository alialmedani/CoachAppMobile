/// A trainee's progress measurement on a date (mirrors backend
/// `ProgressEntryDto`). All measures are optional decimals; no photos.
///
/// [isCoachAuthored] flags entries the coach created: a trainee may only edit or
/// delete their OWN entries (`isCoachAuthored == false`) — the backend rejects a
/// guarded action with a localized business error.
class ProgressEntryModel {
  final String? id;
  final String? traineeId;
  final DateTime? date;
  final double? weightKg;
  final double? bodyFatPercent;
  final double? chestCm;
  final double? waistCm;
  final double? hipsCm;
  final double? armCm;
  final double? thighCm;
  final String? notes;
  final bool isCoachAuthored;

  ProgressEntryModel({
    this.id,
    this.traineeId,
    this.date,
    this.weightKg,
    this.bodyFatPercent,
    this.chestCm,
    this.waistCm,
    this.hipsCm,
    this.armCm,
    this.thighCm,
    this.notes,
    this.isCoachAuthored = false,
  });

  factory ProgressEntryModel.fromJson(Map<String, dynamic> json) {
    double? d(String k) => (json[k] as num?)?.toDouble();
    return ProgressEntryModel(
      id: json['id']?.toString(),
      traineeId: json['traineeId']?.toString(),
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      weightKg: d('weightKg'),
      bodyFatPercent: d('bodyFatPercent'),
      chestCm: d('chestCm'),
      waistCm: d('waistCm'),
      hipsCm: d('hipsCm'),
      armCm: d('armCm'),
      thighCm: d('thighCm'),
      notes: json['notes'],
      isCoachAuthored: json['isCoachAuthored'] ?? false,
    );
  }
}
