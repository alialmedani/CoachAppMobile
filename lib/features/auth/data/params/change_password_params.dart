import 'package:coachappmobile/core/params/base_params.dart';

/// Change-own-password request
/// (`POST api/account/my-profile/change-password`, JSON body).
///
/// Fields are mutable so a future change-password screen can bind them via
/// `onChanged` (the UI surfaces in Profile in a later phase).
class ChangePasswordParams extends BaseParams {
  String currentPassword;
  String newPassword;

  ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
  }
}
