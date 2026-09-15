import 'package:coachappmobile/core/params/base_params.dart';

import '../model/progress_entry_model.dart';

/// Create/update body for a progress entry (`CreateUpdateProgressEntryDto` —
/// same DTO for POST and PUT). `traineeId` + `date` are required; every measure
/// is an optional decimal. [id] targets the update URL only (not the body).
/// Mutable fields so a form can bind them via `onChanged`.
class CreateUpdateProgressEntryParams extends BaseParams {
  String id;
  String traineeId;
  String date; // ISO-8601
  double? weightKg;
  double? bodyFatPercent;
  double? chestCm;
  double? waistCm;
  double? hipsCm;
  double? armCm;
  double? thighCm;
  String? notes;

  CreateUpdateProgressEntryParams({
    this.id = '',
    this.traineeId = '',
    this.date = '',
    this.weightKg,
    this.bodyFatPercent,
    this.chestCm,
    this.waistCm,
    this.hipsCm,
    this.armCm,
    this.thighCm,
    this.notes,
  });

  factory CreateUpdateProgressEntryParams.fromModel(ProgressEntryModel m) {
    return CreateUpdateProgressEntryParams(
      id: m.id ?? '',
      traineeId: m.traineeId ?? '',
      date: (m.date ?? DateTime.now()).toIso8601String(),
      weightKg: m.weightKg,
      bodyFatPercent: m.bodyFatPercent,
      chestCm: m.chestCm,
      waistCm: m.waistCm,
      hipsCm: m.hipsCm,
      armCm: m.armCm,
      thighCm: m.thighCm,
      notes: m.notes,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'traineeId': traineeId, 'date': date};
    if (weightKg != null) map['weightKg'] = weightKg;
    if (bodyFatPercent != null) map['bodyFatPercent'] = bodyFatPercent;
    if (chestCm != null) map['chestCm'] = chestCm;
    if (waistCm != null) map['waistCm'] = waistCm;
    if (hipsCm != null) map['hipsCm'] = hipsCm;
    if (armCm != null) map['armCm'] = armCm;
    if (thighCm != null) map['thighCm'] = thighCm;
    if (notes != null && notes!.trim().isNotEmpty) map['notes'] = notes!.trim();
    return map;
  }
}
