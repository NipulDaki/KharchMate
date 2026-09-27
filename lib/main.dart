import 'package:flutter/material.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/environment/app_environment.dart';
import 'package:kharch_mate/router/app_router.dart';
import 'package:kharch_mate/theme/themes.dart';

/// Application bootstrap entry point with customizable environment.
Future<void> main({
  AppEnvironment environment = AppEnvironment.production,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration
  final config = AppConfig(environment: environment);
  AppConfig.initialize(config);

  // Initialize dependencies with active AppConfig
  await setupServiceLocator(config: config);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.current.appTitle,
      theme: AppThemes.coreTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: AppConfig.current.isDevelopment,
      supportedLocales: const [Locale('en', '')],
    );
  }
}
