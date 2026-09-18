import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharch_mate/database/app_database.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/main.dart';
import 'package:kharch_mate/ui/splash/presentation/splash_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/google_mobile_ads'),
      (MethodCall methodCall) async {
        return null;
      },
    );
  });

  setUp(() async {
    if (serviceLocator.isRegistered<AppDatabase>()) {
      await serviceLocator.reset();
    }
    final appDatabase = AppDatabase();
    await appDatabase.init(customPath: inMemoryDatabasePath);
    await setupServiceLocator();
  });

  tearDown(() async {
    if (serviceLocator.isRegistered<AppDatabase>()) {
      await serviceLocator<AppDatabase>().close();
      await serviceLocator.reset();
    }
  });

  testWidgets('App smoke test loads MaterialApp and SplashScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Track  •  Save  •  Grow'), findsOneWidget);

    // Let splash timer complete
    await tester.pump(const Duration(seconds: 2));
  });
}
