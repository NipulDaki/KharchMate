import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  late FlutterSecureStorage _storage;
  final Map<String, String> _memoryCache = {};

  SecureStorageService() {
    _storage = const FlutterSecureStorage();
  }

  static const String keyHasSeenTutorial = 'has_seen_app_tutorial_v1';
  static const String keyCoachMarkDashboard = 'coach_mark_dashboard_seen_v1';
  static const String keyCoachMarkAddTransaction =
      'coach_mark_add_transaction_seen_v1';
  static const String keyCoachMarkAddCategory =
      'coach_mark_add_category_seen_v1';
  static const String keyCoachMarkSettingsAdFree =
      'coach_mark_settings_ad_free_seen_v1';

  Future writeSecureData(String key, dynamic value) async {
    final strVal = value.toString();
    _memoryCache[key] = strVal;
    try {
      await _storage.write(key: key, value: strVal);
    } catch (_) {}
  }

  Future<String?> getString(String key) async {
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key];
    }
    try {
      if (await _storage.containsKey(key: key)) {
        final val = await _storage.read(key: key);
        if (val != null) {
          _memoryCache[key] = val;
        }
        return val;
      }
    } catch (_) {}
    return null;
  }

  Future<int?> getInt(String key) async {
    final value = await getString(key);
    if (value != null) {
      return int.tryParse(value);
    }
    return null;
  }

  Future<bool?> getBool(String key) async {
    final value = await getString(key);
    if (value != null) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return null;
  }

  Future<double?> getDouble(String key) async {
    final value = await getString(key);
    if (value != null) {
      return double.tryParse(value);
    }
    return null;
  }

  Future<bool> hasSeenTutorial() async {
    final seen = await getBool(keyHasSeenTutorial);
    return seen ?? false;
  }

  Future<void> setTutorialSeen({bool seen = true}) async {
    await writeSecureData(keyHasSeenTutorial, seen.toString());
  }

  Future<bool> hasSeenCoachMark(String key) async {
    final seen = await getBool(key);
    return seen ?? false;
  }

  Future<void> markCoachMarkSeen(String key) async {
    await writeSecureData(key, 'true');
  }

  Future<void> resetAllCoachMarks() async {
    await writeSecureData(keyCoachMarkDashboard, 'false');
    await writeSecureData(keyCoachMarkAddTransaction, 'false');
    await writeSecureData(keyCoachMarkAddCategory, 'false');
    await writeSecureData(keyCoachMarkSettingsAdFree, 'false');
  }

  Future<void> clearStorage() async {
    _memoryCache.clear();
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }
}
