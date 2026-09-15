import 'package:coachappmobile/core/params/base_params.dart';

/// Create body for the trainee's own progress entry (`CreateMyProgressEntryDto`).
/// **Omits `traineeId`** — the server derives it from the caller. Only `date` is
/// required; every measure is an optional decimal.
class CreateMyProgressParams extends BaseParams {
  String date; // ISO-8601
  double? weightKg;
  double? bodyFatPercent;
  double? chestCm;
  double? waistCm;
  double? hipsCm;
  double? armCm;
  double? thighCm;
  String? notes;

  CreateMyProgressParams({
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

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'date': date};
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

/// Update body for the trainee's OWN progress entry (`PUT /my-progress/{id}`).
/// Same shape as [CreateMyProgressParams] (still **omits `traineeId`**); [id]
/// targets the URL only and is never sent in the body. A trainee may only update
/// an entry they authored — the backend rejects a coach-authored one.
class UpdateMyProgressParams extends BaseParams {
  String id;
  String date; // ISO-8601
  double? weightKg;
  double? bodyFatPercent;
  double? chestCm;
  double? waistCm;
  double? hipsCm;
  double? armCm;
  double? thighCm;
  String? notes;

  UpdateMyProgressParams({
    this.id = '',
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

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'date': date};
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
