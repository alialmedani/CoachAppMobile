import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

import '../dialogs/dialogs.dart';

/// Wraps a root/exit-point screen so that a single Android system back press
/// does NOT close the app. The first back at the true root shows a brief
/// snackbar ("اضغط مرة أخرى للخروج") and only a SECOND back within
/// [exitWindow] actually exits the app.
///
/// Uses the modern [PopScope] API (`canPop: false` + `onPopInvokedWithResult`)
/// — NOT the deprecated `WillPopScope`.
///
/// Back-behavior logic:
///  * Pushed screens (not wrapped by this widget) pop on a single back as usual,
///    because [canPop] is only `false` for the wrapped root shells.
///  * For bottom-nav shells, pass [onInterceptBack]. If the shell is on a
///    non-first tab it should switch to the first/home tab and return `true`
///    ("handled — do not exit"). Only when it returns `false` (already on the
///    home tab) does the double-back-to-exit guard kick in.
///  * For shells without tabs, omit [onInterceptBack] and the double-back guard
///    applies directly at the root.
class DoubleBackToClose extends StatefulWidget {
  final Widget child;

  /// Optional hook for bottom-nav shells. Called on each root back press.
  /// Return `true` if the back was handled internally (e.g. switched to the
  /// home tab) and the app should NOT begin the exit countdown.
  /// Return `false` to let the double-back-to-exit guard run.
  final bool Function()? onInterceptBack;

  /// Time window in which a second back press exits the app.
  final Duration exitWindow;

  const DoubleBackToClose({
    super.key,
    required this.child,
    this.onInterceptBack,
    this.exitWindow = const Duration(seconds: 2),
  });

  @override
  State<DoubleBackToClose> createState() => _DoubleBackToCloseState();
}

class _DoubleBackToCloseState extends State<DoubleBackToClose> {
  DateTime? _lastBackAt;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: widget.child,
    );
  }

  void _handleBack() {
    // Give the shell a chance to handle back internally (e.g. return to the
    // first tab). If it does, reset the exit timer and stop here.
    final handled = widget.onInterceptBack?.call() ?? false;
    if (handled) {
      _lastBackAt = null;
      return;
    }

    final now = DateTime.now();
    if (_lastBackAt == null || now.difference(_lastBackAt!) > widget.exitWindow) {
      _lastBackAt = now;
      Dialogs.showSnackBar(message: 'press_back_again_to_exit'.tr());
      return;
    }

    // Second back within the window → actually leave the app.
    Navigator.of(context).maybePop().then((popped) {
      if (!popped) {
        // Root route: close the app to the home screen (Android), instead of
        // killing the process.
        SystemNavigator.pop();
      }
    });
  }
}
