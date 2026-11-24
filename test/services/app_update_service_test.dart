import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/services/app_update_service.dart';
import 'package:kharch_mate/widgets/force_update_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppUpdateService updateService;

  setUp(() {
    updateService = AppUpdateService();
    if (!serviceLocator.isRegistered<AppUpdateService>()) {
      serviceLocator.registerSingleton<AppUpdateService>(updateService);
    }
  });

  tearDown(() {
    if (serviceLocator.isRegistered<AppUpdateService>()) {
      serviceLocator.unregister<AppUpdateService>();
    }
  });

  group('AppUpdateService Tests', () {
    test('initial state has updateInProgress as false', () {
      expect(updateService.isUpdateInProgress, isFalse);
    });

    test('checkForImmediateUpdate gracefully returns null on host platform',
        () async {
      // In host test environment (macOS), Platform.isAndroid is false
      final result = await updateService.checkForImmediateUpdate();
      expect(result, isNull);
      expect(updateService.isUpdateInProgress, isFalse);
    });

    test('resumeUpdateIfInProgress gracefully completes on host platform',
        () async {
      await expectLater(
        updateService.resumeUpdateIfInProgress(),
        completes,
      );
      expect(updateService.isUpdateInProgress, isFalse);
    });

    test('performImmediateUpdate returns failed on host platform', () async {
      final result = await updateService.performImmediateUpdate();
      expect(result, equals(AppUpdateResult.inAppUpdateFailed));
      expect(updateService.isUpdateInProgress, isFalse);
    });

    test('play store URLs are well-formed', () {
      final marketUri = Uri.parse(AppUpdateService.playStoreMarketUrl);
      expect(marketUri.scheme, equals('market'));
      expect(marketUri.host, equals('details'));
      expect(marketUri.queryParameters['id'],
          equals('com.nipuldaki.kharchamate'));

      final webUri = Uri.parse(AppUpdateService.playStoreUrl);
      expect(webUri.scheme, equals('https'));
      expect(webUri.host, equals('play.google.com'));
      expect(webUri.queryParameters['id'], equals('com.nipuldaki.kharchamate'));
    });
  });

  group('ForceUpdateDialog Widget Tests', () {
    testWidgets('renders dialog content and action buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ForceUpdateDialog(),
          ),
        ),
      );

      expect(find.text('Update Required'), findsOneWidget);
      expect(
        find.text(
          'A newer version of KharchMate is available on Google Play. Please update to continue tracking your expenses seamlessly.',
        ),
        findsOneWidget,
      );
      expect(find.text('Exit App'), findsOneWidget);
      expect(find.text('Update Now'), findsOneWidget);
      expect(find.byIcon(Icons.system_update_rounded), findsOneWidget);
    });
  });
}
