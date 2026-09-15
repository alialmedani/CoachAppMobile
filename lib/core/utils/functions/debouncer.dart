import 'dart:async';
import 'dart:ui';

/// Delays running [action] until [delay] has elapsed since the most recent
/// call, coalescing rapid input (e.g. a search field firing on every keystroke)
/// into a single deferred run once the user pauses.
///
/// Only the expensive side effect (a backend re-fetch) should be debounced —
/// keep cheap, immediate UI updates (updating the stored term, toggling a clear
/// button) outside it so the field stays responsive.
class Debouncer {
  Debouncer({this.delay = const Duration(milliseconds: 400)});

  final Duration delay;
  Timer? _timer;

  /// Schedules [action], replacing any still-pending one.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels a pending action without running it (e.g. on clear / immediate
  /// filter changes, or in `dispose`).
  void cancel() => _timer?.cancel();

  /// Whether an action is currently scheduled (exposed for tests).
  bool get isActive => _timer?.isActive ?? false;
}
