import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kharch_mate/services/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('hasSeenTutorial defaults to false and becomes true after setTutorialSeen', () async {
    final storageService = SecureStorageService();

    expect(await storageService.hasSeenTutorial(), isFalse);

    await storageService.setTutorialSeen(seen: true);

    expect(await storageService.hasSeenTutorial(), isTrue);
  });

  test('App session count starts at 0 and increments reliably', () async {
    final storageService = SecureStorageService();

    expect(await storageService.getAppSessionCount(), equals(0));

    final first = await storageService.incrementAppSessionCount();
    expect(first, equals(1));
    expect(await storageService.getAppSessionCount(), equals(1));

    final second = await storageService.incrementAppSessionCount();
    expect(second, equals(2));
    expect(await storageService.getAppSessionCount(), equals(2));
  });

  test('App Open ad last shown timestamp saves and parses correctly', () async {
    final storageService = SecureStorageService();

    expect(await storageService.getAppOpenLastShown(), isNull);

    final testTime = DateTime(2026, 11, 17, 14, 30);
    await storageService.setAppOpenLastShown(testTime);

    final savedTime = await storageService.getAppOpenLastShown();
    expect(savedTime, isNotNull);
    expect(savedTime!.isAtSameMomentAs(testTime), isTrue);
  });
}
