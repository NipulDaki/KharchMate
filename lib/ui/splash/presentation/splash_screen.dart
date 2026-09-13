import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';
import 'package:kharch_mate/router/app_routes.dart';
import 'package:kharch_mate/services/database_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleRouting();
  }

  Future<void> _handleRouting() async {
    // Short delay for smooth visual transition
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    try {
      final dbService = serviceLocator<DatabaseService>();
      final hasUser = await dbService.hasUser();

      if (!mounted) return;

      if (hasUser) {
        context.go(AppRoutes.dashboard.path);
      } else {
        context.go(AppRoutes.welcome.path);
      }
    } catch (_) {
      if (mounted) {
        context.go(AppRoutes.welcome.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SizedBox.expand(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.dimen24,
              vertical: AppDimens.dimen16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 1),

                // 1. Top Brand Block: App Icon + Title + Tagline
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App Icon
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimens.dimen16),
                      child: Image.asset(
                        'assets/images/AppIcons/appstore.png',
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: AppColors.linerGradient,
                              borderRadius: BorderRadius.circular(
                                AppDimens.dimen16,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 40,
                              color: AppColors.white,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: AppDimens.dimen16),

                    // App Name
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Kharch",
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: "Mate",
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimens.dimen6),

                    // Tagline
                    Text(
                      "Track  •  Save  •  Grow",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 1),

                // 2. Center Illustration (scales responsively, centered)
                Flexible(
                  flex: 5,
                  child: Center(
                    child: Image.asset(
                      'assets/images/splash_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 180,
                          height: 180,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBackground,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.savings_rounded,
                            size: 80,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const Spacer(flex: 1),

                // 3. Bottom Footer Quote
                Text(
                  "Better money habits\nfor a brighter tomorrow",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textHint,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: AppDimens.dimen16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
