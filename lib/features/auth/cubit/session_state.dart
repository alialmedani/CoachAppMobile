part of 'session_cubit.dart';

@immutable
abstract class SessionState {}

/// Cold-start state, before [SessionCubit.restoreSession] has run.
class SessionInitial extends SessionState {}

/// No valid session — the user must sign in.
class Unauthenticated extends SessionState {}

/// A token/bootstrap round-trip is in flight (login or session restore).
class Authenticating extends SessionState {}

/// The user is signed in and the session (roles + permissions) is loaded.
class Authenticated extends SessionState {
  final SessionModel session;
  Authenticated(this.session);
}

/// Login (or bootstrap) failed with a user-facing [message].
class AuthError extends SessionState {
  final String message;
  AuthError(this.message);
}
