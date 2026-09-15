import 'package:coachappmobile/core/classes/cashe_helper.dart';
import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/http/api_provider.dart';
import 'package:dio/dio.dart';

import 'params/login_params.dart' show coachAppClientId;

/// Best-effort refresh-token revocation on logout (P19 / M2).
///
/// Uses the OpenIddict **revocation** endpoint (RFC 7009), discovered from the
/// server's well-known configuration so no path is hard-coded. Every failure is
/// swallowed: revocation must never block, delay, or fail sign-out — the local
/// credential wipe is always authoritative. No backend change is required; this
/// only calls endpoints ABP/OpenIddict already exposes.
class TokenRevoker {
  const TokenRevoker._();

  static Future<void> revokeRefreshTokenBestEffort() async {
    final refresh = CacheHelper.refreshtoken;
    if (refresh == null || refresh.isEmpty) return;

    try {
      final revokePath = await _discoverRevocationPath();
      if (revokePath == null) return;

      final headers = <String, String>{};
      if (CacheHelper.tenant.isNotEmpty) {
        headers['__tenant'] = CacheHelper.tenant;
      }

      await ApiProvider.dio.post(
        '$baseUrl$revokePath',
        data: {
          'token': refresh,
          'token_type_hint': 'refresh_token',
          'client_id': coachAppClientId,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: headers,
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          // Best-effort: never throw on a non-2xx (endpoint disabled, etc.).
          validateStatus: (_) => true,
        ),
      );
    } catch (_) {
      // Swallow everything — logout proceeds regardless.
    }
  }

  /// The revocation endpoint PATH (relative to [baseUrl]) from the OpenIddict
  /// discovery document, or null if unavailable. Rebuilding against our own
  /// [baseUrl] keeps it reachable no matter the server's advertised issuer host
  /// (e.g. emulator `10.0.2.2` vs. the server's `localhost`).
  static Future<String?> _discoverRevocationPath() async {
    try {
      final resp = await ApiProvider.dio.get(
        '$baseUrl.well-known/openid-configuration',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          validateStatus: (_) => true,
        ),
      );
      final data = resp.data;
      if (data is Map && data['revocation_endpoint'] is String) {
        final ep = Uri.parse(data['revocation_endpoint'] as String);
        return ep.path.startsWith('/') ? ep.path.substring(1) : ep.path;
      }
    } catch (_) {
      // ignore — treated as "no revocation available"
    }
    return null;
  }
}
