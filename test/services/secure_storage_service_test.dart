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
}
