import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin async wrapper over the platform secure keystore
/// ([flutter_secure_storage]) used for **sensitive credentials only** (the
/// access + refresh tokens). Everything non-sensitive (language, theme, tenant
/// code) stays in Hive via `CacheHelper`.
///
/// - **iOS/macOS:** Keychain, with `first_unlock_this_device` accessibility so
///   the item is not restored to a new device from an iCloud/iTunes backup and
///   is only readable after the first unlock following boot.
/// - **Android:** the plugin's default AES value encryption with a key held in
///   the hardware-backed Android Keystore. (`encryptedSharedPreferences` is left
///   off so the app stays compatible below API 23; values are still ciphertext
///   with a Keystore-guarded key.)
class SecureStore {
  const SecureStore._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static Future<String?> read(String key) => _storage.read(key: key);

  /// Writes [value], or deletes the key when [value] is null/empty (so an empty
  /// token never lingers as ciphertext).
  static Future<void> write(String key, String? value) {
    if (value == null || value.isEmpty) {
      return _storage.delete(key: key);
    }
    return _storage.write(key: key, value: value);
  }

  static Future<void> delete(String key) => _storage.delete(key: key);
}
