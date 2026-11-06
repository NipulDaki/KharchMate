import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/helper/coach_mark_helper.dart';
import 'package:kharch_mate/services/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    if (!serviceLocator.isRegistered<SecureStorageService>()) {
      serviceLocator.registerSingleton<SecureStorageService>(SecureStorageService());
    }
  });

  test('CoachMarkHelper creates TargetFocus with accurate identify and contents', () {
    final key = GlobalKey();
    final target = CoachMarkHelper.createTarget(
      identify: 'test_target',
      keyTarget: key,
      title: 'Test Title',
      description: 'Test Description',
      stepIndex: 1,
      totalSteps: 3,
      icon: Icons.star,
    );

    expect(target.identify, 'test_target');
    expect(target.keyTarget, key);
    expect(target.contents, isNotEmpty);
  });

  test('Coach mark storage tracking records seen status and supports reset', () async {
    final storage = serviceLocator<SecureStorageService>();

    expect(
      await storage.hasSeenCoachMark(SecureStorageService.keyCoachMarkDashboard),
      isFalse,
    );

    await storage.markCoachMarkSeen(SecureStorageService.keyCoachMarkDashboard);

    expect(
      await storage.hasSeenCoachMark(SecureStorageService.keyCoachMarkDashboard),
      isTrue,
    );

    await storage.resetAllCoachMarks();

    expect(
      await storage.hasSeenCoachMark(SecureStorageService.keyCoachMarkDashboard),
      isFalse,
    );
  });

  testWidgets('showTutorial immediately marks storageKey as seen preventing re-trigger on redirect', (tester) async {
    final storage = serviceLocator<SecureStorageService>();
    final key = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Container(key: key, child: const Text('Target Widget')),
        ),
      ),
    );

    expect(await storage.hasSeenCoachMark(SecureStorageService.keyCoachMarkDashboard), isFalse);

    // Call showTutorial
    final future = CoachMarkHelper.showTutorial(
      context: tester.element(find.byType(Scaffold)),
      storageKey: SecureStorageService.keyCoachMarkDashboard,
      targets: [
        CoachMarkHelper.createTarget(
          identify: 'test',
          keyTarget: key,
          title: 'T',
          description: 'D',
          stepIndex: 1,
          totalSteps: 1,
        ),
      ],
    );

    // Pump timer so async markCoachMarkSeen completes
    await tester.pump(const Duration(milliseconds: 500));

    // Check that storageKey was marked as seen
    expect(await storage.hasSeenCoachMark(SecureStorageService.keyCoachMarkDashboard), isTrue);

    CoachMarkHelper.dismissActiveTutorial();
    await tester.pumpAndSettle();
    await future;
  });
}
