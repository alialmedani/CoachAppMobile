/// Coalesces concurrent calls to the same async action into a **single**
/// in-flight execution. While one run is pending, every other caller receives
/// the same `Future`; once it completes, the next call starts fresh.
///
/// Used to make token refresh single-flight: when several authenticated
/// requests notice an expired token at once, they must not each spend the
/// one-time-use refresh token (rotation would invalidate all but the first and
/// bounce the user to login). See `token_validator.dart`.
class SingleFlight<T> {
  Future<T>? _inFlight;

  /// Runs [action], or returns the already-running future if one is in flight.
  Future<T> run(Future<T> Function() action) {
    return _inFlight ??= action().whenComplete(() => _inFlight = null);
  }

  /// Whether a run is currently in flight (exposed for tests/diagnostics).
  bool get isRunning => _inFlight != null;
}
