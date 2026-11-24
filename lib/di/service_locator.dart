import 'package:get_it/get_it.dart';
import 'package:kharch_mate/database/app_database.dart';
import 'package:kharch_mate/environment/app_environment.dart';
import 'package:kharch_mate/router/app_router.dart';
import 'package:kharch_mate/services/ad_service.dart';
import 'package:kharch_mate/services/analytics_service.dart';
import 'package:kharch_mate/services/app_update_service.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:kharch_mate/services/notification_service.dart';
import 'package:kharch_mate/services/secure_storage_service.dart';
import 'package:kharch_mate/services/theme_service.dart';

final serviceLocator = GetIt.instance;

Future<void> setupServiceLocator({AppConfig? config}) async {
  final appConfig = config ?? AppConfig.current;
  AppConfig.initialize(appConfig);

  // Initialize Firebase Analytics
  final analyticsService = AnalyticsService();
  await analyticsService.init();
  await analyticsService.logAppOpen();

  final appDatabase = AppDatabase();
  await appDatabase.init();

  final databaseService = DatabaseService(appDatabase: appDatabase);

  final secureStorage = SecureStorageService();
  final themeService = ThemeService(
    databaseService,
    secureStorage,
  );
  await themeService.init();

  final adService = AdService(
    storageService: secureStorage,
    appConfig: appConfig,
  );
  await adService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  final appUpdateService = AppUpdateService();

  serviceLocator
    // App Environment Configuration
    ..registerSingleton<AppConfig>(appConfig)
    // Analytics Service
    ..registerSingleton<AnalyticsService>(analyticsService)
    // App Update Service
    ..registerSingleton<AppUpdateService>(appUpdateService)
    // Database and Persistence Service
    ..registerSingleton<AppDatabase>(appDatabase)
    ..registerSingleton<DatabaseService>(databaseService)
    // Theme service
    ..registerSingleton<ThemeService>(themeService)
    // Secure storage service
    ..registerSingleton<SecureStorageService>(secureStorage)
    // AdMob Ads & Reward Service
    ..registerSingleton<AdService>(adService)
    // Local Notification Service
    ..registerSingleton<NotificationService>(notificationService)
    // Application Routing
    ..registerLazySingleton(() => AppRouter());
}
