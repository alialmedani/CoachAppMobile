import 'package:coachappmobile/features/auth/data/params/refresh_token_params.dart';
import 'package:coachappmobile/features/auth/data/repository/auth_repository.dart';

import '../../classes/cashe_helper.dart';

/// Called by `RemoteDataSource` before every authenticated request.
///
/// If the cached access token has expired, it attempts a silent refresh via the
/// OpenIddict `refresh_token` grant and persists the new token/expiry. When no
/// refresh token is available (e.g. the client wasn't granted `offline_access`)
/// or the refresh fails, the cached credentials are cleared so the
/// next authenticated request is unauthenticated and the app falls back to the
/// login screen (logout-on-expiry).
///
/// The refresh call itself is unauthenticated (`connect/token`), so it does not
/// recurse back through this check.
Future<void> checkToken() async {
  final token = CacheHelper.token;
  if (token == null || token.isEmpty) return;

  final DateTime? expiryDate = CacheHelper.datenow;
  if (expiryDate == null) return;

  // Still valid — nothing to do.
  if (DateTime.now().isBefore(expiryDate)) return;

  final refreshToken = CacheHelper.refreshtoken;
  if (refreshToken == null || refreshToken.isEmpty) {
    // No refresh token: end the session on expiry.
    await CacheHelper.clearToken();
    return;
  }

  final result = await AuthRepository().refreshRequest(
    params: RefreshTokenParams(refreshToken: refreshToken),
  );

  if (result.hasDataOnly) {
    final newToken = result.data!;
    await CacheHelper.setToken(newToken.accessToken);
    await CacheHelper.setRefreshToken(newToken.refreshToken);
    if (newToken.expiresIn != null) {
      await CacheHelper.setExpiresIn(newToken.expiresIn);
      await CacheHelper.setDateWithExpiry(newToken.expiresIn!);
    }
  } else {
    // Refresh rejected (expired/revoked) — clear so the app returns to login.
    await CacheHelper.clearToken();
  }
}
