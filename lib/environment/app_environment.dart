import 'dart:io';

/// Application running environments.
enum AppEnvironment { staging, development, production }

/// Application configuration holding environment-specific settings,
/// API URLs, and Google AdMob ad unit & app keys.
class AppConfig {
  final AppEnvironment environment;
  final String? customApiUrl;
  final String? customBannerAdId;
  final String? customRewardedAdId;

  const AppConfig({
    required this.environment,
    this.customApiUrl,
    this.customBannerAdId,
    this.customRewardedAdId,
  });

  /// Active global configuration instance.
  /// Defaults to [AppEnvironment.development].
  static AppConfig _current = const AppConfig(
    environment: AppEnvironment.development,
  );

  /// Get the current active application configuration.
  static AppConfig get current => _current;

  /// Initialize the application configuration at app startup.
  static void initialize(AppConfig config) {
    _current = config;
  }

  // ===========================================================================
  // ENVIRONMENT HELPERS
  // ===========================================================================

  /// Returns `true` if current environment is [AppEnvironment.production].
  bool get isProduction => environment == AppEnvironment.production;

  /// Returns `true` if current environment is [AppEnvironment.staging].
  bool get isStaging => environment == AppEnvironment.staging;

  /// Returns `true` if current environment is [AppEnvironment.development].
  bool get isDevelopment => environment == AppEnvironment.development;

  /// Human-readable environment display name.
  String get environmentName {
    switch (environment) {
      case AppEnvironment.staging:
        return 'Staging';
      case AppEnvironment.development:
        return 'Development';
      case AppEnvironment.production:
        return 'Production';
    }
  }

  /// App display title according to environment.
  String get appTitle {
    switch (environment) {
      case AppEnvironment.staging:
        return 'KharchMate (Staging)';
      case AppEnvironment.development:
        return 'KharchMate (Dev)';
      case AppEnvironment.production:
        return 'KharchMate';
    }
  }

  // ===========================================================================
  // API URL CONFIGURATION
  // ===========================================================================

  /// Resolves the base API URL based on active [AppEnvironment].
  String get apiUrl {
    if (customApiUrl != null && customApiUrl!.isNotEmpty) {
      return customApiUrl!;
    }
    switch (environment) {
      case AppEnvironment.staging:
        return '';
      case AppEnvironment.production:
        return '';
      case AppEnvironment.development:
        return '';
    }
  }

  // ===========================================================================
  // ADMOB KEYS & AD UNIT IDs
  // ===========================================================================

  // Production AdMob App IDs
  static const String prodAndroidAppId =
      'ca-app-pub-9185976312211555~7770386179';
  static const String prodIosAppId = 'ca-app-pub-9185976312211555~5536948384';

  // Production AdMob Ad Unit IDs
  static const String prodAndroidBannerId =
      'ca-app-pub-9185976312211555/2800683417';
  static const String prodAndroidRewardedId =
      'ca-app-pub-9185976312211555/7141674098';

  static const String prodIosBannerId =
      'ca-app-pub-9185976312211555/2078628683';
  static const String prodIosRewardedId =
      'ca-app-pub-9185976312211555/8316733971';

  // Google Official Test App IDs
  static const String testAndroidAppId =
      'ca-app-pub-3940256099942544~3347511713';
  static const String testIosAppId = 'ca-app-pub-3940256099942544~1458002511';

  // Google Official Test Ad Unit IDs (used in dev and staging to prevent policy strikes)
  static const String testAndroidBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String testAndroidRewardedId =
      'ca-app-pub-3940256099942544/5224354917';

  static const String testIosBannerId =
      'ca-app-pub-3940256099942544/2934735716';
  static const String testIosRewardedId =
      'ca-app-pub-3940256099942544/1712485313';

  // ===========================================================================
  // PLATFORM & ENVIRONMENT ADMOB RESOLVERS
  // ===========================================================================

  /// Resolves the AdMob App ID based on platform and active environment.
  String get adMobAppId {
    if (Platform.isAndroid) {
      return isProduction ? prodAndroidAppId : testAndroidAppId;
    } else if (Platform.isIOS) {
      return isProduction ? prodIosAppId : testIosAppId;
    }
    return testAndroidAppId;
  }

  /// Resolves Banner Ad Unit ID based on platform and active environment.
  String get bannerAdUnitId {
    if (customBannerAdId != null && customBannerAdId!.isNotEmpty) {
      return customBannerAdId!;
    }
    if (Platform.isAndroid) {
      return isProduction ? prodAndroidBannerId : testAndroidBannerId;
    } else if (Platform.isIOS) {
      return isProduction ? prodIosBannerId : testIosBannerId;
    }
    return testAndroidBannerId;
  }

  /// Resolves Rewarded Video Ad Unit ID based on platform and active environment.
  String get rewardedAdUnitId {
    if (customRewardedAdId != null && customRewardedAdId!.isNotEmpty) {
      return customRewardedAdId!;
    }
    if (Platform.isAndroid) {
      return isProduction ? prodAndroidRewardedId : testAndroidRewardedId;
    } else if (Platform.isIOS) {
      return isProduction ? prodIosRewardedId : testIosRewardedId;
    }
    return testAndroidRewardedId;
  }
}
