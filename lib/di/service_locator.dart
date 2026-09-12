import 'package:get_it/get_it.dart';
import 'package:kharch_mate/router/app_router.dart';
import 'package:kharch_mate/services/secure_storage_service.dart';

final serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  serviceLocator
    //Secure storage service
    ..registerLazySingleton(() => SecureStorageService())
    // Application Routing
    ..registerLazySingleton(() => AppRouter());
}
