import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kharch_mate/router/app_routes.dart';
import 'package:kharch_mate/ui/categories/presentation/add_category_screen.dart';
import 'package:kharch_mate/ui/categories/presentation/categories_screen.dart';
import 'package:kharch_mate/ui/dashboard/presentation/dashboard_screen.dart';
import 'package:kharch_mate/ui/onboarding/presentation/user_name_screen.dart';
import 'package:kharch_mate/ui/onboarding/presentation/welcome_screen.dart';
import 'package:kharch_mate/ui/settings/presentation/help_support_screen.dart';
import 'package:kharch_mate/ui/settings/presentation/privacy_policy_screen.dart';
import 'package:kharch_mate/ui/settings/presentation/settings_screen.dart';
import 'package:kharch_mate/ui/settings/presentation/terms_screen.dart';
import 'package:kharch_mate/ui/settings/presentation/user_profile_screen.dart';
import 'package:kharch_mate/ui/splash/presentation/splash_screen.dart';
import 'package:kharch_mate/models/transaction_item.dart';
import 'package:kharch_mate/ui/transaction/presentation/add_transaction_screen.dart';
import 'package:kharch_mate/ui/transaction/presentation/transaction_details_screen.dart';
import 'package:kharch_mate/ui/reports/presentation/reports_screen.dart';
import 'package:kharch_mate/ui/transaction/presentation/transactions_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
String? pendingRedirectLocation;

class AppRouter {
  static final _rootTabNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.splash.path,
    debugLogDiagnostics: true,
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(
        name: AppRoutes.splash.name,
        path: AppRoutes.splash.path,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: AppRoutes.welcome.name,
        path: AppRoutes.welcome.path,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        name: AppRoutes.userName.name,
        path: AppRoutes.userName.path,
        builder: (context, state) => const UserNameScreen(),
      ),
      GoRoute(
        name: AppRoutes.dashboard.name,
        path: AppRoutes.dashboard.path,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        name: AppRoutes.categories.name,
        path: AppRoutes.categories.path,
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        name: AppRoutes.addCategory.name,
        path: AppRoutes.addCategory.path,
        builder: (context, state) => const AddCategoryScreen(),
      ),
      GoRoute(
        name: AppRoutes.settings.name,
        path: AppRoutes.settings.path,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        name: AppRoutes.privacyPolicy.name,
        path: AppRoutes.privacyPolicy.path,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        name: AppRoutes.termsOfUse.name,
        path: AppRoutes.termsOfUse.path,
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        name: AppRoutes.helpSupport.name,
        path: AppRoutes.helpSupport.path,
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        name: AppRoutes.userProfile.name,
        path: AppRoutes.userProfile.path,
        builder: (context, state) => const UserProfileScreen(),
      ),
      GoRoute(
        name: AppRoutes.transaction.name,
        path: AppRoutes.transaction.path,
        builder: (context, state) => const TransactionsScreen(),
      ),
      GoRoute(
        name: AppRoutes.addTransaction.name,
        path: AppRoutes.addTransaction.path,
        builder: (context, state) => AddTransactionScreen(
          initialTransaction: state.extra as TransactionItem?,
        ),
      ),
      GoRoute(
        name: AppRoutes.transactionDetails.name,
        path: AppRoutes.transactionDetails.path,
        builder: (context, state) => TransactionDetailsScreen(
          transaction: state.extra as TransactionItem?,
        ),
      ),
      GoRoute(
        name: AppRoutes.report.name,
        path: AppRoutes.report.path,
        builder: (context, state) => const ReportsScreen(),
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
