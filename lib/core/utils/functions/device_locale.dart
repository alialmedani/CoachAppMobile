import 'package:flutter/widgets.dart';

/// The language code to use when the app **follows the device**: the system
/// locale if it's one the app supports (`ar` / `en`), otherwise Arabic (the
/// RTL-first default).
///
/// Shared by the startup locale resolver (`main.dart`) and the "reset to device
/// language" action in the language switcher, so the follow-device rule is
/// defined in exactly one place.
String deviceFollowLanguageCode() {
  final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  return code == 'en' ? 'en' : 'ar';
}
