import 'package:coachappmobile/core/utils/functions/single_flight.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests the coalescing guard behind single-flight token refresh (P19/M1):
/// concurrent callers must share ONE execution so the one-time-use refresh
/// token is spent exactly once.
void main() {
  test('coalesces concurrent calls into a single execution', () async {
    final sf = SingleFlight<int>();
    var runs = 0;

    Future<int> action() async {
      runs++;
      await Future<void>.delayed(const Duration(milliseconds: 30));
      return 42;
    }

    final results = await Future.wait([
      sf.run(action),
      sf.run(action),
      sf.run(action),
    ]);

    expect(runs, 1, reason: 'action must run once for concurrent callers');
    expect(results, [42, 42, 42]);
    expect(sf.isRunning, isFalse, reason: 'clears in-flight after completion');
  });

  test('runs again after the previous flight completes', () async {
    final sf = SingleFlight<int>();
    var runs = 0;
    Future<int> action() async {
      runs++;
      return runs;
    }

    final first = await sf.run(action);
    final second = await sf.run(action);

    expect(first, 1);
    expect(second, 2);
    expect(runs, 2);
  });

  test('propagates errors and still clears the in-flight slot', () async {
    final sf = SingleFlight<int>();
    Future<int> boom() async => throw StateError('nope');

    await expectLater(sf.run(boom), throwsStateError);
    expect(sf.isRunning, isFalse);

    // A subsequent successful call works (slot was cleared).
    final ok = await sf.run(() async => 7);
    expect(ok, 7);
  });
}
