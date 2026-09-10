import 'package:flutter/foundation.dart';
import '../../classes/cashe_helper.dart';

/// Called by `RemoteDataSource` before an authenticated request.
///
/// It checks whether the cached access token has expired. Silent token refresh
/// is intentionally NOT wired yet: in the reference app it called the auth
/// feature's `RefreshTokenUsecase`, which does not exist in CoachApp until the
/// auth feature is built.
///
/// TODO(CoachApp): when the auth feature exists, re-add refresh here —
/// on expiry call the CoachApp refresh-token usecase against `connect/token`
/// (grant_type=refresh_token) and persist the new token/expiry via CacheHelper.
Future<void> checkToken() async {
  final token = CacheHelper.token;
  if (token == null || token.isEmpty) return;

  final DateTime? expiryDate = CacheHelper.datenow;
  if (expiryDate == null) return;

  if (DateTime.now().isAfter(expiryDate) && kDebugMode) {
    debugPrint('Access token expired — refresh not yet wired (auth feature pending).');
  }
}
