import 'package:easy_localization/easy_localization.dart';

/// Iraqi money formatting — used everywhere money is shown.
///
/// Iraqi Dinar is displayed with thousands grouping and no fraction digits
/// (e.g. `1,234,567`), with a localized currency label (`IQD` / `د.ع`).

final NumberFormat _iqdGroup = NumberFormat('#,##0', 'en_US');

/// Localized currency label: `IQD` (en) / `د.ع` (ar).
String iqdSymbol() => 'IQD'.tr();

/// Grouped amount without currency, e.g. `1,234,567`.
String formatAmount(num? amount) => _iqdGroup.format(amount ?? 0);

/// Money with grouped digits + localized currency, e.g. `1,234,567 IQD`.
String formatMoney(num? amount) => '${formatAmount(amount)} ${iqdSymbol()}';

/// Compact money for tight spaces (chart labels, small badges), e.g. `1.2M IQD`.
/// Falls back to the grouped format below 1,000.
String formatMoneyCompact(num? amount) {
  final v = (amount ?? 0).toDouble();
  final a = v.abs();
  final String n;
  if (a >= 1000000) {
    n = '${(v / 1000000).toStringAsFixed(1)}M';
  } else if (a >= 1000) {
    n = '${(v / 1000).toStringAsFixed(1)}K';
  } else {
    n = formatAmount(v);
  }
  return '$n ${iqdSymbol()}';
}
