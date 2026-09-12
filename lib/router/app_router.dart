import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kharch_mate/router/app_routes.dart';
import 'package:kharch_mate/ui/splash/presentation/splash_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
String? pendingRedirectLocation;

class AppRouter {
  //static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _rootTabNavigatorKey = GlobalKey<NavigatorState>();

  //static final GlobalKey<State<StatefulWidget>> buttonKey = GlobalKey();
  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.splash.path,
    debugLogDiagnostics: true,
    navigatorKey: rootNavigatorKey,
    //refreshListenable: authState,
    routes: [
      //Splash
      GoRoute(
        name: AppRoutes.splash.name,
        path: AppRoutes.splash.path,
        builder: (context, state) {
          return SplashScreen();
          // return BlocProvider(
          //   create: (context) => LoginCubit(serviceLocator<LoginRepository>()),
          //   child: const StartupPage(),
          // );
        },
      ),
    ],
    redirect: (context, state) async {
      return null;
    },
  );

  static GoRouter get router => _router;

  static void pop() {
    final context = _rootTabNavigatorKey.currentContext;
    if (context != null && context.canPop()) {
      context.pop();
    }
  }
}
