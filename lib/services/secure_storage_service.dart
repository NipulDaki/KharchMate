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
  static const String keyAppOpenAdLastShownTimestamp =
      'app_open_ad_last_shown_timestamp_v1';
  static const String keyAppSessionCount = 'app_session_count_v1';
  static const String keyThemeMode = 'app_theme_mode_v1';

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

  /// Retrieves the timestamp when an App Open Ad was last displayed.
  Future<DateTime?> getAppOpenLastShown() async {
    final iso = await getString(keyAppOpenAdLastShownTimestamp);
    if (iso != null && iso.isNotEmpty) {
      return DateTime.tryParse(iso);
    }
    return null;
  }

  /// Persists the timestamp of an App Open Ad impression.
  Future<void> setAppOpenLastShown(DateTime timestamp) async {
    await writeSecureData(
      keyAppOpenAdLastShownTimestamp,
      timestamp.toIso8601String(),
    );
  }

  /// Retrieves the lifetime count of completed app launch sessions.
  Future<int> getAppSessionCount() async {
    final count = await getInt(keyAppSessionCount);
    return count ?? 0;
  }

  /// Increments and persists the app launch session count. Returns the new count.
  Future<int> incrementAppSessionCount() async {
    final current = await getAppSessionCount();
    final next = current + 1;
    await writeSecureData(keyAppSessionCount, next.toString());
    return next;
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
