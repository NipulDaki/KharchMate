import 'package:get_it/get_it.dart';
import 'package:kharch_mate/database/app_database.dart';
import 'package:kharch_mate/router/app_router.dart';
import 'package:kharch_mate/services/ad_service.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:kharch_mate/services/secure_storage_service.dart';

final serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  final appDatabase = AppDatabase();
  await appDatabase.init();

  final secureStorage = SecureStorageService();
  final adService = AdService(storageService: secureStorage);
  await adService.init();

  serviceLocator
    // Database and Persistence Service
    ..registerSingleton<AppDatabase>(appDatabase)
    ..registerLazySingleton<DatabaseService>(
      () => DatabaseService(appDatabase: serviceLocator<AppDatabase>()),
    )
    // Secure storage service
    ..registerSingleton<SecureStorageService>(secureStorage)
    // AdMob Ads & Reward Service
    ..registerSingleton<AdService>(adService)
    // Application Routing
    ..registerLazySingleton(() => AppRouter());
}
