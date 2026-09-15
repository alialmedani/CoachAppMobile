import 'package:easy_localization/easy_localization.dart';

/// Formats a nutrition portion for display. A meal/log item's `quantity` is the
/// **number of servings**; the real amount the trainee eats is
/// `quantity × servingSize servingUnit` (e.g. 2 × 100 g = 200 g). These helpers
/// surface both so a servings count is never mistaken for grams.
///
/// When the serving size/unit are missing (older data) they gracefully fall back
/// to a plain servings count.
class ServingDisplay {
  const ServingDisplay._();

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  static bool _resolvable(double servingSize, String? unit) =>
      servingSize > 0 && unit != null && unit.isNotEmpty;

  /// Verbose portion for read-only detail rows, e.g. "2 servings (2 × 100 g)".
  static String full(double quantity, double servingSize, String? unit) {
    if (!_resolvable(servingSize, unit)) {
      return 'quantity_servings_value'.tr(args: [_n(quantity)]);
    }
    return 'serving_portion_full'.tr(
      args: [_n(quantity), _n(quantity), _n(servingSize), unit!],
    );
  }

  /// Compact portion for badges / list chips, e.g. "2 × 100 g".
  static String compact(double quantity, double servingSize, String? unit) {
    if (!_resolvable(servingSize, unit)) {
      return 'quantity_servings_value'.tr(args: [_n(quantity)]);
    }
    return 'serving_portion'.tr(args: [_n(quantity), _n(servingSize), unit!]);
  }

  /// Resolved real amount for helper text under an editable quantity field,
  /// e.g. "≈ 200 g" — or `null` when it can't be resolved.
  static String? resolvedAmount(
    double quantity,
    double servingSize,
    String? unit,
  ) {
    if (!_resolvable(servingSize, unit)) return null;
    return 'serving_amount_resolved'.tr(
      args: [_n(quantity * servingSize), unit!],
    );
  }
}
