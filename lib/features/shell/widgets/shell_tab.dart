import 'package:flutter/widgets.dart';

/// Definition of a single bottom-navigation tab inside a role shell.
///
/// A tab is pure configuration: its label (a translation key), the icons for
/// the selected / unselected states, and the full-screen [body] rendered inside
/// the shell's [IndexedStack]. The shells build these lists dynamically from the
/// signed-in user's granted permissions.
class ShellTab {
  /// snake_case translation key for the tab label (translated at render time).
  final String labelKey;

  /// Icon shown when this tab is selected.
  final IconData activeIcon;

  /// Icon shown when this tab is not selected.
  final IconData inactiveIcon;

  /// The full-screen body rendered for this tab.
  final Widget body;

  const ShellTab({
    required this.labelKey,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.body,
  });
}
