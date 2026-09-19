import 'dart:io';

/// Centralized configuration for Google AdMob Ad Unit IDs and App IDs.
///
/// NOTE: By default, this uses Google's official Test Ad Unit IDs so you can test
/// safely during development without triggering policy violations.
/// Replace the `production` constants with your real AdMob Ad Unit IDs when publishing.
class AdMobConstants {
  AdMobConstants._();

  /// Set this to `true` to use your live production AdMob Ad Units.
  /// Keep `false` during development and testing to use Google test ads safely.
  static const bool isProduction = false;

  // ===========================================================================
  // PRODUCTION ADMOB IDs (Paste your IDs from AdMob Console here)
  // ===========================================================================
  // AdMob App: 7770386179
  static const String prodAndroidBannerId =
      'ca-app-pub-9185976312211555/2800683417';
  static const String prodAndroidRewardedId =
      'ca-app-pub-9185976312211555/7141674098';

  static const String prodIosBannerId =
      'ca-app-pub-9185976312211555/2078628683';
  static const String prodIosRewardedId =
      'ca-app-pub-9185976312211555/8316733971';

  // ===========================================================================
  // GOOGLE OFFICIAL TEST AD UNIT IDs (Always active when isProduction == false)
  // ===========================================================================
  // Android Test IDs
  static const String testAndroidBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String testAndroidRewardedId =
      'ca-app-pub-3940256099942544/5224354917';

  // iOS Test IDs
  static const String testIosBannerId =
      'ca-app-pub-3940256099942544/2934735716';
  static const String testIosRewardedId =
      'ca-app-pub-3940256099942544/1712485313';

  /// Resolves the Banner Ad Unit ID based on platform and production flag.
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return isProduction ? prodAndroidBannerId : testAndroidBannerId;
    } else if (Platform.isIOS) {
      return isProduction ? prodIosBannerId : testIosBannerId;
    }
    return testAndroidBannerId;
  }

  /// Resolves the Rewarded Video Ad Unit ID based on platform and production flag.
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return isProduction ? prodAndroidRewardedId : testAndroidRewardedId;
    } else if (Platform.isIOS) {
      return isProduction ? prodIosRewardedId : testIosRewardedId;
    }
    return testAndroidRewardedId;
  }
}
