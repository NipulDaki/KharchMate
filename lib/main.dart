import 'package:flutter/material.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/environment/app_environment.dart';
import 'package:kharch_mate/helper/coach_mark_helper.dart';
import 'package:kharch_mate/router/app_router.dart';
import 'package:kharch_mate/services/ad_service.dart';
import 'package:kharch_mate/services/app_update_service.dart';
import 'package:kharch_mate/services/theme_service.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: _handleAppResume,
    );
  }

  void _handleAppResume() {
    if (serviceLocator.isRegistered<AppUpdateService>()) {
      serviceLocator<AppUpdateService>().resumeUpdateIfInProgress();
    }

    if (!serviceLocator.isRegistered<AdService>()) return;

    final adService = serviceLocator<AdService>();
    adService.showAppOpenAdOnResume(
      canShowCheck: () {
        final isSafeRoute = AppRouteObserver.isCurrentRouteSafeForAds;
        final isCoachMarkShowing = CoachMarkHelper.isShowing;
        final isUpdateActive =
            serviceLocator.isRegistered<AppUpdateService>() &&
                serviceLocator<AppUpdateService>().isUpdateInProgress;
        return isSafeRoute && !isCoachMarkShowing && !isUpdateActive;
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = serviceLocator<ThemeService>();

    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        return MaterialApp.router(
          title: AppConfig.current.appTitle,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeService.themeMode,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: AppConfig.current.isDevelopment,
          supportedLocales: const [Locale('en', '')],
        );
      },
    );
  }
}
