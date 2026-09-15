import 'package:coachappmobile/core/params/base_params.dart';

/// Body for `PUT /api/app/my-profile` — the trainee's restricted self-edit.
/// Only contact details are editable: [phoneNumber], [email] and [birthDate].
/// Username is immutable, and goals/targets/height/weights stay coach-owned, so
/// none of those are ever sent. Mutable fields so the form can bind them via
/// `onChanged`. A field is omitted from the body when empty/unset.
class UpdateMyProfileParams extends BaseParams {
  String? phoneNumber;
  String? email;

  /// ISO-8601 date (date-only is fine); `null` leaves it unset.
  String? birthDate;

  UpdateMyProfileParams({this.phoneNumber, this.email, this.birthDate});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (phoneNumber != null && phoneNumber!.trim().isNotEmpty) {
      map['phoneNumber'] = phoneNumber!.trim();
    }
    if (email != null && email!.trim().isNotEmpty) {
      map['email'] = email!.trim();
    }
    if (birthDate != null && birthDate!.isNotEmpty) {
      map['birthDate'] = birthDate;
    }
    return map;
  }
}
