import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharch_mate/environment/app_environment.dart';
import 'package:kharch_mate/services/ad_service.dart';
import 'package:kharch_mate/services/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SecureStorageService storageService;
  late AdService adService;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    storageService = SecureStorageService();
    adService = AdService(
      storageService: storageService,
      appConfig: AppConfig.current,
    );
  });

  tearDown(() async {
    await adService.dispose();
  });

  test('grantAdFreePass defaults to 3 days duration', () async {
    expect(adService.isAdFree, isFalse);

    final before = DateTime.now();
    final granted = await adService.grantAdFreePass();

    expect(granted, isTrue);
    expect(adService.isAdFree, isTrue);
    expect(adService.adFreeUntil, isNotNull);

    // Verify expiry is approximately 3 days from now
    final expiry = adService.adFreeUntil!;
    final diff = expiry.difference(before);
    expect(diff.inHours, greaterThanOrEqualTo(71));
    expect(diff.inHours, lessThanOrEqualTo(72));
  });

  group('App Open Ad - Conservative Rules & Frequency Tests', () {
    test('App Open Ad suppressed on first installs (session count < 3)', () {
      adService.setMockSessionCount(1);
      expect(adService.sessionCount, equals(1));
      expect(adService.canShowAppOpenAdNow, isFalse);

      adService.setMockSessionCount(2);
      expect(adService.sessionCount, equals(2));
      expect(adService.canShowAppOpenAdNow, isFalse);
    });

    test('Cooldown is active when last ad was shown less than 4 hours ago', () {
      final now = DateTime.now();
      // Shown 1 hour ago
      adService.setMockLastShownTimestamp(now.subtract(const Duration(hours: 1)));

      expect(adService.isCooldownActive, isTrue);
      expect(adService.remainingCooldown, isNotNull);
      expect(adService.remainingCooldown!.inMinutes, greaterThan(170));
      expect(adService.canShowAppOpenAdNow, isFalse);
    });

    test('Cooldown is inactive when last ad was shown more than 4 hours ago or never', () {
      expect(adService.isCooldownActive, isFalse);
      expect(adService.remainingCooldown, isNull);

      final now = DateTime.now();
      adService.setMockLastShownTimestamp(now.subtract(const Duration(hours: 5)));
      expect(adService.isCooldownActive, isFalse);
    });

    test('Ad-Free pass completely suppresses App Open Ad', () async {
      adService.setMockSessionCount(5);
      expect(adService.isAdFree, isFalse);

      await adService.grantAdFreePass();
      expect(adService.isAdFree, isTrue);
      expect(adService.canShowAppOpenAdNow, isFalse);
    });

    test('Stale cached ad (> 4 hours) is treated as expired and unavailable', () {
      // Set load time to 5 hours ago
      final fiveHoursAgo = DateTime.now().subtract(const Duration(hours: 5));
      adService.setMockAppOpenLoadTime(fiveHoursAgo);

      expect(adService.isAppOpenAdAvailable, isFalse);
    });
  });
}
