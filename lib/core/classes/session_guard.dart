/// Bridges the HTTP layer (core) to the auth session (feature) without a
/// core→feature import: `main.dart` registers [onUnauthorized] to invalidate the
/// [SessionCubit], and `ApiProvider` calls [notifyUnauthorized] when an
/// authenticated request comes back `401` during normal use (a token the client
/// still believed valid was rejected — e.g. revoked server-side or clock skew).
///
/// The registered handler is expected to be idempotent (invalidating an
/// already-signed-out session is a no-op), so repeated 401s from concurrent
/// requests are safe.
class SessionGuard {
  const SessionGuard._();

  static void Function()? onUnauthorized;

  static void notifyUnauthorized() => onUnauthorized?.call();
}
