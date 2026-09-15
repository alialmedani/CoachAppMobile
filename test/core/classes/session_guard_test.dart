import 'package:coachappmobile/core/classes/session_guard.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests the HTTP→session bridge used for mid-session 401 handling (P19/L3).
void main() {
  tearDown(() => SessionGuard.onUnauthorized = null);

  test('notifyUnauthorized invokes the registered handler', () {
    var calls = 0;
    SessionGuard.onUnauthorized = () => calls++;

    SessionGuard.notifyUnauthorized();
    SessionGuard.notifyUnauthorized();

    expect(calls, 2);
  });

  test('notifyUnauthorized is a no-op when no handler is registered', () {
    SessionGuard.onUnauthorized = null;
    expect(SessionGuard.notifyUnauthorized, returnsNormally);
  });
}
