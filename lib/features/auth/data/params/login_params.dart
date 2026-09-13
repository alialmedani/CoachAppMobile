import 'package:coachappmobile/core/params/base_params.dart';

/// OpenIddict public client id for the CoachApp mobile app.
/// (Seeded in C:\src\BACK\CoachApp OpenIddictDataSeedContributor — no secret.)
const String coachAppClientId = 'CoachApp_App';

/// Scope string requested at login. `offline_access` asks for a refresh token;
/// it may be silently ignored until the backend seeds that scope (gap B1).
const String coachAppScopes =
    'CoachApp offline_access profile email phone roles';

/// Login request for the OAuth2 **password grant**
/// (`application/x-www-form-urlencoded`).
///
/// [tenantCode] is the gym/coach code. It is NOT part of the body — it is sent
/// as the ABP `__tenant` header (persisted via `CacheHelper.setTenant` before
/// the token call), so [toJson] emits only the form fields.
///
/// Fields are mutable so the login screen can bind them via `onChanged`.
class LoginParams extends BaseParams {
  String username;
  String password;
  String tenantCode;

  LoginParams({
    required this.username,
    required this.password,
    required this.tenantCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'grant_type': 'password',
      'client_id': coachAppClientId,
      'scope': coachAppScopes,
      'username': username,
      'password': password,
    };
  }
}
