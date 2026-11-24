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

  test('grantAdFreePass defaults to 1 day duration', () async {
    expect(adService.isAdFree, isFalse);

    final before = DateTime.now();
    final granted = await adService.grantAdFreePass();

    expect(granted, isTrue);
    expect(adService.isAdFree, isTrue);
    expect(adService.adFreeUntil, isNotNull);

    // Verify expiry is approximately 1 day from now
    final expiry = adService.adFreeUntil!;
    final diff = expiry.difference(before);
    expect(diff.inHours, greaterThanOrEqualTo(23));
    expect(diff.inHours, lessThanOrEqualTo(24));
  });

  test('grantAdFreePass does not extend if already active', () async {
    await adService.grantAdFreePass();
    final firstExpiry = adService.adFreeUntil;

    final secondAttempt = await adService.grantAdFreePass();
    expect(secondAttempt, isFalse);
    expect(adService.adFreeUntil, equals(firstExpiry));
  });

  test('remainingAdFreeText returns Inactive when not ad-free', () {
    expect(adService.remainingAdFreeText, equals('Inactive'));
  });

  test('isAppOpenAdAvailable is false initially when no ad loaded', () {
    expect(adService.isAppOpenAdAvailable, isFalse);
  });

  test('Ad-Free pass suppresses App Open Ad availability', () async {
    await adService.grantAdFreePass();
    expect(adService.isAdFree, isTrue);
    expect(adService.isAppOpenAdAvailable, isFalse);
  });
}
