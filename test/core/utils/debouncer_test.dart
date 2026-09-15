import 'package:coachappmobile/core/utils/functions/debouncer.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests the search-input debouncer (P18): rapid input must collapse into a
/// single deferred run so the backend isn't hit per keystroke.
void main() {
  test('runs once after rapid calls, using the most recent action', () async {
    final d = Debouncer(delay: const Duration(milliseconds: 40));
    var runs = 0;
    var last = 0;
    d.run(() {
      runs++;
      last = 1;
    });
    d.run(() {
      runs++;
      last = 2;
    });
    d.run(() {
      runs++;
      last = 3;
    });

    expect(runs, 0, reason: 'nothing runs before the delay elapses');
    expect(d.isActive, isTrue);

    await Future<void>.delayed(const Duration(milliseconds: 90));

    expect(runs, 1, reason: 'the three rapid calls collapse into one run');
    expect(last, 3, reason: 'only the latest scheduled action survives');
    expect(d.isActive, isFalse);
  });

  test('cancel prevents a pending run', () async {
    final d = Debouncer(delay: const Duration(milliseconds: 40));
    var runs = 0;
    d.run(() => runs++);
    d.cancel();

    await Future<void>.delayed(const Duration(milliseconds: 90));

    expect(runs, 0);
    expect(d.isActive, isFalse);
  });

  test('a new run after completion fires again', () async {
    final d = Debouncer(delay: const Duration(milliseconds: 30));
    var runs = 0;

    d.run(() => runs++);
    await Future<void>.delayed(const Duration(milliseconds: 70));
    expect(runs, 1);

    d.run(() => runs++);
    await Future<void>.delayed(const Duration(milliseconds: 70));
    expect(runs, 2);
  });

  test('defaults to a 400ms delay', () {
    expect(Debouncer().delay, const Duration(milliseconds: 400));
  });
}
