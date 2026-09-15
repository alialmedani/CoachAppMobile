import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Shows the standard "discard unsaved changes?" confirm dialog.
///
/// Returns `true` if the user chose to **discard** (leave the screen), `false`
/// to keep editing. Uses the same keys as the plan builders so every
/// create/edit screen reads identically: `unsaved_changes`,
/// `unsaved_changes_message`, `keep_editing`, `discard`.
Future<bool> showDiscardChangesDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('unsaved_changes'.tr()),
      content: Text('unsaved_changes_message'.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('keep_editing'.tr()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(
            foregroundColor: AppDesignSystem.errorColor,
          ),
          child: Text('discard'.tr()),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Wraps a create/edit screen so any back navigation prompts a discard-changes
/// confirm while [isDirty] returns `true`.
///
/// Both the system/gesture back **and** the [AppTopBar] back button route
/// through [Navigator.maybePop], which respects this [PopScope]; so a single
/// wrapper guards every exit path. [isDirty] is read live at pop time (not at
/// build time), so screens do not need to rebuild when their draft changes.
///
/// A successful save must pop via `Navigator.pop(context, true)` — that is a
/// direct pop and bypasses the guard, so saving is never intercepted. Only
/// *abandoning* the screen (which pops `null`, i.e. "no refresh") is guarded.
class UnsavedChangesGuard extends StatelessWidget {
  /// Evaluated at pop time; return `true` when there is unsaved work.
  final bool Function() isDirty;
  final Widget child;

  const UnsavedChangesGuard({
    super.key,
    required this.isDirty,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (!isDirty()) {
          navigator.pop(result);
          return;
        }
        final discard = await showDiscardChangesDialog(context);
        if (discard && navigator.mounted) navigator.pop();
      },
      child: child,
    );
  }
}
