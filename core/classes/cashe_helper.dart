import 'package:hive_flutter/hive_flutter.dart';

import '../constant/end_points/cashe_helper_constant.dart';
 
class CacheHelper {
  static Box<dynamic>? _box;
  static Box<dynamic>? _wishlistBox;
  static Box<dynamic>? _cartBox;
  static Box<dynamic>? _currentUserBox;
  static Box<dynamic>? _settingBox;
  static bool _isInitialized = false;

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
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  static Future<void> setLang(String value) => box.put(languageValue, value);
  static Future<void> setTenant(String value) => box.put(tenantName, value);

  static Future<void> setToken(String? value) =>
      box.put(accessToken, value ?? '');
  static Future<void> setDeviceToken(String? value) =>
      box.put(deviceToken, value ?? '');
  static Future<void> setRefreshToken(String? value) =>
      box.put(refreshToken, value ?? '');
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
    if (!box.containsKey(accessToken)) return null;
    return "${box.get(accessToken)}";
  }

  static String? get getDeviceToken {
    if (!box.containsKey(deviceToken)) return null;
    return "${box.get(deviceToken)}";
  }

  static String? get refreshtoken {
    if (!box.containsKey(refreshToken)) return null;
    return "${box.get(refreshToken)}";
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

  static Future<void> clearToken() async {
    await box.delete(accessToken);
    await box.delete(refreshToken);
    await box.delete(userId);
    await box.delete(organizationId);
    await box.delete(expiresIn);
    await box.delete(date);
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
