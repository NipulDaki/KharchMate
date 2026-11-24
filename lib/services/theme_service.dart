import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kharch_mate/models/user_profile.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:kharch_mate/services/secure_storage_service.dart';

class ThemeService extends ChangeNotifier {
  final DatabaseService _dbService;
  final SecureStorageService _storageService;

  ThemeMode _themeMode = ThemeMode.light;
  StreamSubscription<UserProfile>? _userProfileSubscription;

  ThemeService(this._dbService, this._storageService);

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Initializes the saved theme mode from SecureStorage or SQLite database.
  Future<void> init() async {
    try {
      final savedMode =
          await _storageService.getString(SecureStorageService.keyThemeMode);

      if (savedMode != null && savedMode.isNotEmpty) {
        _themeMode = _parseThemeMode(savedMode);
      } else {
        // Fallback to SQLite UserProfile
        final profile = await _dbService.getUserProfile();
        if (profile != null) {
          _themeMode = profile.isDarkMode ? ThemeMode.dark : ThemeMode.light;
        }
      }
    } catch (_) {}

    // Listen for external profile changes
    _userProfileSubscription = _dbService.onUserProfileChanged.listen((profile) {
      final modeFromProfile =
          profile.isDarkMode ? ThemeMode.dark : ThemeMode.light;
      if (_themeMode != modeFromProfile) {
        _themeMode = modeFromProfile;
        notifyListeners();
      }
    });

    notifyListeners();
  }

  /// Sets and persists the app [ThemeMode].
  Future<void> updateThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      await _storageService.writeSecureData(
        SecureStorageService.keyThemeMode,
        mode.name,
      );
      await _dbService.updateDarkMode(mode == ThemeMode.dark);
    } catch (_) {}
  }

  /// Toggles between Light and Dark mode.
  Future<void> toggleDarkMode(bool isDark) async {
    await updateThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value.toLowerCase()) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  @override
  void dispose() {
    _userProfileSubscription?.cancel();
    super.dispose();
  }
}
