library;

enum AppRoutes {
  root,
  splash,
  // dashboard,
  // transation,
  // addTransaction,
  // transctionDetails,
  // report,
  // budget,
  // settings,
}

extension AppRouteExtension on AppRoutes {
  String get path {
    switch (this) {
      case AppRoutes.root:
        return '/';
      case AppRoutes.splash:
        return '/splash';
      // case AppRoutes.dashboard:
      //   return '/dashboard';
      // case AppRoutes.transation:
      //   return '/transation';
      // case AppRoutes.addTransaction:
      //  return '/addTransaction';
      // case AppRoutes.transctionDetails:
      //   return '/transctionDetails';
      // case AppRoutes.report:
      //   return '/report';
      // case AppRoutes.budget:
      //   return '/budget';
      // case AppRoutes.settings:
      //   return '/setting';
    }
  }

  String get name {
    switch (this) {
      case AppRoutes.root:
        return 'Root';
      case AppRoutes.splash:
        return 'Splash';
      // case AppRoutes.dashboard:
      //   // TODO: Handle this case.
      //   throw UnimplementedError();
      // case AppRoutes.transation:
      //   // TODO: Handle this case.
      //   throw UnimplementedError();
      // case AppRoutes.addTransaction:
      //   // TODO: Handle this case.
      //   throw UnimplementedError();
      // case AppRoutes.transctionDetails:
      //   // TODO: Handle this case.
      //   throw UnimplementedError();
      // case AppRoutes.report:
      //   // TODO: Handle this case.
      //   throw UnimplementedError();
      // case AppRoutes.budget:
      //   // TODO: Handle this case.
      //   throw UnimplementedError();
      // case AppRoutes.settings:
      //   return 'Setting';
    }
  }
}
