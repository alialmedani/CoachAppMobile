import 'package:coachappmobile/core/constant/end_points/api_url.dart';
import 'package:coachappmobile/core/data_source/remote_data_source.dart';
import 'package:coachappmobile/core/http/http_method.dart';
import 'package:coachappmobile/core/repository/core_repository.dart';
import 'package:coachappmobile/core/results/result.dart';

import '../model/session_model.dart';
import '../model/token_model.dart';
import '../params/bootstrap_session_params.dart';
import '../params/change_password_params.dart';
import '../params/login_params.dart';
import '../params/refresh_token_params.dart';

/// Auth/session data layer. All endpoint constants live in
/// `core/constant/end_points/api_url.dart` (single source of URLs).
class AuthRepository extends CoreRepository {
  /// OAuth2 password grant → `connect/token`.
  ///
  /// Unauthenticated (no bearer yet) and form-urlencoded. The gym/coach code is
  /// carried by the `__tenant` header (persisted before this call), not the body.
  Future<Result<TokenModel>> loginRequest({
    required LoginParams params,
  }) async {
    final result = await RemoteDataSource.request<TokenModel>(
      withAuthentication: false,
      url: loginUrl,
      method: HttpMethod.POST,
      contentType: 'application/x-www-form-urlencoded',
      data: params.toJson(),
      converter: (json) => TokenModel.fromJson(json),
    );

    return call(result: result);
  }

  /// OAuth2 refresh_token grant → `connect/token` (same endpoint, form-urlencoded).
  Future<Result<TokenModel>> refreshRequest({
    required RefreshTokenParams params,
  }) async {
    final result = await RemoteDataSource.request<TokenModel>(
      withAuthentication: false,
      url: loginUrl,
      method: HttpMethod.POST,
      contentType: 'application/x-www-form-urlencoded',
      data: params.toJson(),
      converter: (json) => TokenModel.fromJson(json),
    );

    return call(result: result);
  }

  /// ABP session bootstrap → `api/abp/application-configuration`.
  ///
  /// Authenticated: derives roles + granted permissions + current tenant.
  Future<Result<SessionModel>> bootstrapRequest({
    required BootstrapSessionParams params,
  }) async {
    final result = await RemoteDataSource.request<SessionModel>(
      withAuthentication: true,
      url: appConfigUrl,
      method: HttpMethod.GET,
      converter: (json) => SessionModel.fromJson(json),
    );

    return call(result: result);
  }

  /// Change own password → `api/account/my-profile/change-password` (JSON body,
  /// no meaningful response body).
  Future<Result<String>> changePasswordRequest({
    required ChangePasswordParams params,
  }) async {
    final result = await RemoteDataSource.noModelRequest(
      withAuthentication: true,
      url: changePasswordUrl,
      method: HttpMethod.POST,
      data: params.toJson(),
    );

    return noModelCall(result: result);
  }
}
