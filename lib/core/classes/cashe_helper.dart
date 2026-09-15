import 'package:hive_flutter/hive_flutter.dart';
import 'package:coachappmobile/core/classes/secure_store.dart';
import 'package:coachappmobile/core/constant/end_points/cashe_helper_constant.dart';

class CacheHelper {
  static Box<dynamic>? _box;
  static Box<dynamic>? _wishlistBox;
  static Box<dynamic>? _cartBox;
  static Box<dynamic>? _currentUserBox;
  static Box<dynamic>? _settingBox;
  static bool _isInitialized = false;

  // Sensitive credentials (access + refresh token) live in the platform secure
  // store, NOT in the plaintext Hive box. These in-memory copies back the
  // synchronous [token]/[refreshtoken] getters that the request pipeline relies
  // on; they are hydrated from secure storage in [init] before the first frame
  // and kept in lock-step on every write/clear.
  static String? _accessTokenValue;
  static String? _refreshTokenValue;

  static Box<dynamic> get box {
    if (_box == null) {
      _ensureSyncInit();
    }
    return _box!;
  }

  static Box<dynamic> get wishlistBox {
    if (_wishlistBox == null) {
      _ensureSyncInit();
    }
    return _wishlistBox!;
  }

  static Box<dynamic> get cartBox {
    if (_cartBox == null) {
      _ensureSyncInit();
    }
    return _cartBox!;
  }

  static Box<dynamic> get currentUserBox {
    if (_currentUserBox == null) {
      _ensureSyncInit();
    }
    return _currentUserBox!;
  }

  static Box<dynamic> get settingBox {
    if (_settingBox == null && _box == null) {
      _ensureSyncInit();
    }
    return _settingBox ?? _box!;
  }

  static void _ensureSyncInit() {
    if (!_isInitialized) {
      throw Exception(
        'CacheHelper not initialized. Call await CacheHelper.init() in main() before using CacheHelper.',
      );
    }
  }

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      // Hive.registerAdapter(CurrentCustomerModelAdapter());
      _box = await Hive.openBox("default_box");
      _wishlistBox = await Hive.openBox("model_box");
      _cartBox = await Hive.openBox("cart_box");
      _currentUserBox = await Hive.openBox("current_user_box");
      _settingBox = await Hive.openBox("setting_box");
      _isInitialized = true;
      await _hydrateSecureTokens();
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  /// Loads the tokens from secure storage into memory, and migrates any token
  /// left in the legacy plaintext Hive box (from a build before secure storage)
  /// into the secure store — then removes it from Hive so it never lingers in
  /// plaintext.
  static Future<void> _hydrateSecureTokens() async {
    _accessTokenValue = await SecureStore.read(accessToken);
    _refreshTokenValue = await SecureStore.read(refreshToken);

    final legacyAccess = _box!.get(accessToken);
    if ((_accessTokenValue == null || _accessTokenValue!.isEmpty) &&
        legacyAccess is String &&
        legacyAccess.isNotEmpty) {
      _accessTokenValue = legacyAccess;
      await SecureStore.write(accessToken, legacyAccess);
    }
    final legacyRefresh = _box!.get(refreshToken);
    if ((_refreshTokenValue == null || _refreshTokenValue!.isEmpty) &&
        legacyRefresh is String &&
        legacyRefresh.isNotEmpty) {
      _refreshTokenValue = legacyRefresh;
      await SecureStore.write(refreshToken, legacyRefresh);
    }
    await _box!.delete(accessToken);
    await _box!.delete(refreshToken);
  }

  static Future<void> setLang(String value) => box.put(languageValue, value);
  static Future<void> setTenant(String value) => box.put(tenantName, value);

  static Future<void> setToken(String? value) async {
    _accessTokenValue = value;
    await SecureStore.write(accessToken, value);
  }

  static Future<void> setDeviceToken(String? value) =>
      box.put(deviceToken, value ?? '');

  static Future<void> setRefreshToken(String? value) async {
    _refreshTokenValue = value;
    await SecureStore.write(refreshToken, value);
  }
  static Future<void> setUserId(String? value) => box.put(userId, value ?? 0);
  static Future<void> setOrganizationId(String? value) =>
      box.put(organizationId, value ?? '');
  static Future<void> setRealEstateId(String? value) =>
      box.put(realestateId, value ?? 0);
  static Future<void> setExpiresIn(int? value) =>
      box.put(expiresIn, value ?? 0);
  static Future<void> setFirstTime(bool value) => box.put(isFirstTime, value);

  static Future<void> setTheme(String value) => box.put('app_theme', value);

  static Future<void> setPrimaryHex(String hex) =>
      settingBox.put(kPrimaryHex, hex);

  static Future<void> setSecondaryHex(String hex) =>
      settingBox.put(kSecondaryHex, hex);

  static Future<void> setLogoPath(String? path) async {
    if (path == null) return;
    await settingBox.put(kLogoPath, path);
  }

  static Future<void> setDateWithExpiry(int expiresInSeconds) {
    DateTime expiryDateTime = DateTime.now().add(
      Duration(seconds: expiresInSeconds),
    );
    return box.put(date, expiryDateTime);
  }

  static Future<void> setTopics(List<String> topics) async {
    await box.put('fcm_topics', topics);
  }

  ////////////////////////////////Get///////////////////////////////

  static String get lang => box.get(languageValue) ?? 'ar';
  static String get tenant => box.get(tenantName) ?? '';
  static String get theme => box.get('app_theme', defaultValue: 'light');
  static String? get token {
    final t = _accessTokenValue;
    return (t == null || t.isEmpty) ? null : t;
  }

  static String? get getDeviceToken {
    if (!box.containsKey(deviceToken)) return null;
    return "${box.get(deviceToken)}";
  }

  static String? get refreshtoken {
    final t = _refreshTokenValue;
    return (t == null || t.isEmpty) ? null : t;
  }

  static String? get userID {
    if (!box.containsKey(userId)) return null;
    return "${box.get(userId)}";
  }

  static String? get organizationID {
    if (!box.containsKey(organizationId)) return null;
    return "${box.get(organizationId)}";
  }

  static String? get realestateID {
    if (!box.containsKey(realestateId)) return null;
    return "${box.get(realestateId)}";
  }

  static bool get firstTime => box.get(isFirstTime) ?? true;
  static int? get expiresin => box.get(expiresIn);
  static DateTime? get datenow => box.get(date);

  static String get primaryHex => settingBox.get(kPrimaryHex, defaultValue: '');
  static String get secondaryHex =>
      settingBox.get(kSecondaryHex, defaultValue: '');
  static String? get logoPath => settingBox.get(kLogoPath);

  static void deleteCertificates() {
    setToken(null);
    setUserId(null);
  }

  /// Clears the authentication credentials (secure tokens) and their Hive-side
  /// session metadata. Non-credential device prefs (lang/theme/tenant) are kept.
  static Future<void> clearToken() async {
    _accessTokenValue = null;
    _refreshTokenValue = null;
    await SecureStore.delete(accessToken);
    await SecureStore.delete(refreshToken);
    // Remove any legacy plaintext copies too (pre-migration builds).
    await box.delete(accessToken);
    await box.delete(refreshToken);
    await box.delete(userId);
    await box.delete(organizationId);
    await box.delete(expiresIn);
    await box.delete(date);
  }

  /// Full sign-out cleanup: credentials + all user-scoped local state and
  /// caches. Deliberately preserves device-level preferences the next user
  /// benefits from — language, theme, the last tenant code (to prefill login),
  /// and the first-run flag.
  static Future<void> clearSession() async {
    await clearToken();
    await box.delete('fcm_topics');
    await box.delete('stored_accounts_list');
    await box.delete(userModel);
    await box.delete(customerInfo);
    await box.delete(rememberMe);
    await currentUserBox.clear();
    await wishlistBox.clear();
    await cartBox.clear();
  }

  static List<String> getTopics() {
    final data = box.get('fcm_topics');
    if (data == null) return [];
    return List<String>.from(data);
  }

  static Future<void> saveAccountsList(
    List<Map<String, dynamic>> accounts,
  ) async {
    await box.put('stored_accounts_list', accounts);
  }

  static List<Map<String, dynamic>> getAccountsList() {
    final data = box.get('stored_accounts_list');
    if (data == null) return [];
    // Hive returns dynamic lists, need to cast safely
    return (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
