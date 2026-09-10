import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../ui/dialogs/dialogs.dart';

/// Normalize a (mostly Iraqi) phone number into international digits for wa.me.
///
/// Strips non-digits, drops a leading `00`, keeps an existing `964`, and turns a
/// local leading `0` into the Iraq country code (964). Returns '' when there are
/// no digits to work with.
String normalizeIraqiPhone(String phone) {
  var d = phone.replaceAll(RegExp(r'[^\d]'), '');
  if (d.isEmpty) return '';
  if (d.startsWith('00')) d = d.substring(2);
  if (d.startsWith('964')) return d;
  if (d.startsWith('0')) d = d.substring(1);
  return '964$d';
}

/// Open a WhatsApp chat with [rawPhone], optionally pre-filling [message].
/// Shows a snackbar if the number is unusable or WhatsApp can't be opened.
Future<void> openWhatsApp(String? rawPhone, {String? message}) async {
  final number = normalizeIraqiPhone(rawPhone ?? '');
  if (number.isEmpty) {
    Dialogs.showSnackBar(message: 'whatsapp_invalid_number'.tr());
    return;
  }

  final query = (message != null && message.isNotEmpty)
      ? '?text=${Uri.encodeComponent(message)}'
      : '';
  final uri = Uri.parse('https://wa.me/$number$query');

  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) Dialogs.showSnackBar(message: 'whatsapp_not_available'.tr());
  } catch (_) {
    Dialogs.showSnackBar(message: 'whatsapp_not_available'.tr());
  }
}
