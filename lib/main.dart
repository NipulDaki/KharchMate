import 'package:flutter/material.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/router/app_router.dart';
import 'package:kharch_mate/theme/themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KharchMate',
      theme: AppThemes.coreTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale('en', '')],
    );
  }
}
