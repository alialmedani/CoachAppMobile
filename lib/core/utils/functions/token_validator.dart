import 'package:coachappmobile/features/auth/data/params/refresh_token_params.dart';
import 'package:coachappmobile/features/auth/data/repository/auth_repository.dart';

import '../../classes/cashe_helper.dart';
import 'single_flight.dart';

/// Single-flight guard so concurrent expired requests share ONE refresh.
final SingleFlight<bool> _refreshFlight = SingleFlight<bool>();

/// Refreshes the access token via the OpenIddict `refresh_token` grant, at most
/// once at a time. Concurrent callers await the same in-flight refresh, so the
/// one-time-use refresh token is spent exactly once (rotation stays consistent).
///
/// Returns `true` on success. On any failure — or when there is no refresh token
/// — the cached credentials are cleared so the next request is unauthenticated
/// and the app falls back to login. This is the single, shared refresh entry
/// point used by both [checkToken] and `SessionCubit`.
Future<bool> refreshAccessToken() => _refreshFlight.run(_doRefresh);

Future<bool> _doRefresh() async {
  final refreshToken = CacheHelper.refreshtoken;
  if (refreshToken == null || refreshToken.isEmpty) {
    await CacheHelper.clearToken();
    return false;
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
    return true;
  }

  // Refresh rejected (expired/revoked) — clear so the app returns to login.
  await CacheHelper.clearToken();
  return false;
}

/// Called by `RemoteDataSource` before every authenticated request.
///
/// If the cached access token has expired, it triggers a (single-flight) silent
/// refresh via [refreshAccessToken]. The refresh call itself is unauthenticated
/// (`connect/token`), so it does not recurse back through this check.
Future<void> checkToken() async {
  final token = CacheHelper.token;
  if (token == null || token.isEmpty) return;

  final DateTime? expiryDate = CacheHelper.datenow;
  if (expiryDate == null) return;

  // Still valid — nothing to do.
  if (DateTime.now().isBefore(expiryDate)) return;

  await refreshAccessToken();
}
