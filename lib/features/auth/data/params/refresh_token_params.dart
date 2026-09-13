import 'package:coachappmobile/core/params/base_params.dart';
import 'package:coachappmobile/features/auth/data/params/login_params.dart';

/// Silent token refresh via the OAuth2 **refresh_token grant**
/// (`application/x-www-form-urlencoded`), same `connect/token` endpoint.
class RefreshTokenParams extends BaseParams {
  String refreshToken;

  RefreshTokenParams({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {
      'grant_type': 'refresh_token',
      'client_id': coachAppClientId,
      'refresh_token': refreshToken,
    };
  }
}
