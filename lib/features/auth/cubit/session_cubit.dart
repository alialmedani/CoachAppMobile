import 'package:bloc/bloc.dart';
import 'package:coachappmobile/core/classes/cashe_helper.dart';
import 'package:meta/meta.dart';

import '../data/model/session_model.dart';
import '../data/model/token_model.dart';
import '../data/params/bootstrap_session_params.dart';
import '../data/params/login_params.dart';
import '../data/params/refresh_token_params.dart';
import '../data/repository/auth_repository.dart';
import '../data/usecase/bootstrap_session_usecase.dart';
import '../data/usecase/login_usecase.dart';
import '../data/usecase/refresh_token_usecase.dart';

part 'session_state.dart';

/// App-level session holder.
///
/// This is the one documented exception to the "no `emit()` in a feature cubit"
/// rule: [SessionCubit] owns global session state (Unauthenticated /
/// Authenticating / Authenticated / AuthError), so it emits directly rather
/// than driving a boilerplate widget. The UseCases still return `Result<T>`;
/// this cubit orchestrates the multi-step login (token → persist → bootstrap).
class SessionCubit extends Cubit<SessionState> {
  SessionCubit() : super(SessionInitial());

  final AuthRepository _repository = AuthRepository();

  /// Bound to the login form via `onChanged`.
  LoginParams loginParams = LoginParams(
    username: '',
    password: '',
    tenantCode: '',
  );

  /// The current session once authenticated (null when signed out).
  SessionModel? session;

  String? _lastError;

  // ----- role / permission helpers (read by the role gate + feature screens) -
  bool get isCoach => session?.isCoach ?? false;
  bool get isTrainee => session?.isTrainee ?? false;
  bool can(String policy) => session?.can(policy) ?? false;

  /// Sign in: persist the tenant (so `__tenant` attaches), fetch a token,
  /// persist it, then bootstrap the ABP session.
  Future<void> login() async {
    emit(Authenticating());

    // Persist the gym/coach code BEFORE the token call so RemoteDataSource
    // attaches the `__tenant` header to the request.
    await CacheHelper.setTenant(loginParams.tenantCode.trim());

    final tokenResult = await LoginUsecase(_repository).call(
      params: loginParams,
    );

    if (tokenResult.hasErrorOnly) {
      emit(AuthError(tokenResult.error ?? 'login_failed'));
      return;
    }

    await _persistToken(tokenResult.data!);

    if (await _bootstrap()) {
      emit(Authenticated(session!));
    } else {
      emit(AuthError(_lastError ?? 'login_failed'));
    }
  }

  /// Cold-start restore: if a token is cached, bootstrap; if it is expired and
  /// a refresh token exists, refresh first; otherwise sign out.
  Future<void> restoreSession() async {
    if (state is Authenticated) return;

    final token = CacheHelper.token;
    if (token == null || token.isEmpty) {
      emit(Unauthenticated());
      return;
    }

    emit(Authenticating());

    final expiry = CacheHelper.datenow;
    final isExpired = expiry != null && DateTime.now().isAfter(expiry);
    if (isExpired && !await _tryRefresh()) {
      await _clearSession();
      return;
    }

    if (await _bootstrap()) {
      emit(Authenticated(session!));
    } else {
      // Token no longer valid (e.g. 401) — drop back to the login screen.
      await _clearSession();
    }
  }

  /// Sign out: clear all cached credentials and reset the session.
  Future<void> logout() async {
    loginParams = LoginParams(username: '', password: '', tenantCode: '');
    await _clearSession();
  }

  // --------------------------------------------------------------------------
  Future<bool> _tryRefresh() async {
    final refresh = CacheHelper.refreshtoken;
    if (refresh == null || refresh.isEmpty) return false;

    final result = await RefreshTokenUsecase(_repository).call(
      params: RefreshTokenParams(refreshToken: refresh),
    );

    if (result.hasDataOnly) {
      await _persistToken(result.data!);
      return true;
    }
    return false;
  }

  Future<bool> _bootstrap() async {
    final result = await BootstrapSessionUsecase(_repository).call(
      params: BootstrapSessionParams(),
    );

    if (result.hasDataOnly) {
      session = result.data;
      await CacheHelper.setUserId(session!.userId);
      return true;
    }

    _lastError = result.error;
    return false;
  }

  Future<void> _persistToken(TokenModel token) async {
    await CacheHelper.setToken(token.accessToken);
    // refresh_token may be absent (backend gap B1) — store whatever we got.
    await CacheHelper.setRefreshToken(token.refreshToken);
    if (token.expiresIn != null) {
      await CacheHelper.setExpiresIn(token.expiresIn);
      await CacheHelper.setDateWithExpiry(token.expiresIn!);
    }
  }

  Future<void> _clearSession() async {
    await CacheHelper.clearToken();
    session = null;
    emit(Unauthenticated());
  }
}
