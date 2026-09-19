library;

enum AppRoutes {
  root,
  splash,
  welcome,
  userName,
  dashboard,
  transaction,
  addTransaction,
  transactionDetails,
  report,
  budget,
  settings,
  categories,
  addCategory,
  privacyPolicy,
  termsOfUse,
  helpSupport,
  userProfile,
}

extension AppRouteExtension on AppRoutes {
  String get path {
    switch (this) {
      case AppRoutes.root:
        return '/';
      case AppRoutes.splash:
        return '/splash';
      case AppRoutes.welcome:
        return '/welcome';
      case AppRoutes.userName:
        return '/user-name';
      case AppRoutes.dashboard:
        return '/dashboard';
      case AppRoutes.transaction:
        return '/transaction';
      case AppRoutes.addTransaction:
        return '/add-transaction';
      case AppRoutes.transactionDetails:
        return '/transaction-details';
      case AppRoutes.report:
        return '/report';
      case AppRoutes.budget:
        return '/budget';
      case AppRoutes.settings:
        return '/settings';
      case AppRoutes.categories:
        return '/categories';
      case AppRoutes.addCategory:
        return '/add-category';
      case AppRoutes.privacyPolicy:
        return '/privacy-policy';
      case AppRoutes.termsOfUse:
        return '/terms-of-use';
      case AppRoutes.helpSupport:
        return '/help-support';
      case AppRoutes.userProfile:
        return '/user-profile';
    }
  }

  String get name {
    switch (this) {
      case AppRoutes.root:
        return 'Root';
      case AppRoutes.splash:
        return 'Splash';
      case AppRoutes.welcome:
        return 'Welcome';
      case AppRoutes.userName:
        return 'UserName';
      case AppRoutes.dashboard:
        return 'Dashboard';
      case AppRoutes.transaction:
        return 'Transaction';
      case AppRoutes.addTransaction:
        return 'AddTransaction';
      case AppRoutes.transactionDetails:
        return 'TransactionDetails';
      case AppRoutes.report:
        return 'Report';
      case AppRoutes.budget:
        return 'Budget';
      case AppRoutes.settings:
        return 'Settings';
      case AppRoutes.categories:
        return 'Categories';
      case AppRoutes.addCategory:
        return 'AddCategory';
      case AppRoutes.privacyPolicy:
        return 'PrivacyPolicy';
      case AppRoutes.termsOfUse:
        return 'TermsOfUse';
      case AppRoutes.helpSupport:
        return 'HelpSupport';
      case AppRoutes.userProfile:
        return 'UserProfile';
    }
  }
}
