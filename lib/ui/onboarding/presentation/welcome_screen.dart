import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';
import 'package:kharch_mate/router/app_routes.dart';
import 'package:kharch_mate/widgets/app_text_button.dart';

class TutorialItem {
  final String imagePath;
  final String title;
  final String subtitle;
  final IconData fallbackIcon;
  final bool isAppIcon;

  const TutorialItem({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.fallbackIcon,
    this.isAppIcon = false,
  });
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoChangeTimer;

  static const List<TutorialItem> _tutorials = [
    TutorialItem(
      imagePath: 'assets/images/tutorial.png',
      title: "Take Control\nof Your Finances",
      subtitle: "Track your income, expenses, set budgets and build a better financial future.",
      fallbackIcon: Icons.trending_up_rounded,
    ),
    TutorialItem(
      imagePath: 'assets/images/splash_logo.png',
      title: "Smart Budgets\n& Limit Alerts",
      subtitle: "Set category budgets with real-time alerts so you never exceed your planned limits.",
      fallbackIcon: Icons.account_balance_wallet_rounded,
    ),
    TutorialItem(
      imagePath: 'assets/images/tutorial_reports.png',
      title: "Visual Reports\n& Wealth Growth",
      subtitle:
          "Understand your spending habits with intuitive category breakdowns and monthly trends.",
      fallbackIcon: Icons.pie_chart_rounded,
      isAppIcon: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoChangeTimer();
  }

  void _startAutoChangeTimer() {
    _autoChangeTimer?.cancel();
    _autoChangeTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _tutorials.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoChangeTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final illustrationSize = (size.width * 0.58).clamp(180.0, 240.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.dimen24,
            vertical: AppDimens.dimen12,
          ),
          child: Column(
            children: [
              // Top Bar with Skip
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.userName.path),
                  child: Text(
                    "Skip",
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // PageView with 3 Tutorial Slides
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _tutorials.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = _tutorials[index];

                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: AppDimens.dimen12),

                          // Illustration Graphic
                          Container(
                            width: illustrationSize,
                            height: illustrationSize,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBackground,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  blurRadius: 28,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Center(
                              child: item.isAppIcon
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        AppDimens.dimen24,
                                      ),
                                      child: Image.asset(
                                        item.imagePath,
                                        width: illustrationSize * 0.65,
                                        height: illustrationSize * 0.65,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                                  item.fallbackIcon,
                                                  size: 80,
                                                  color: AppColors.primary,
                                                ),
                                      ),
                                    )
                                  : Image.asset(
                                      item.imagePath,
                                      width: illustrationSize * 0.85,
                                      height: illustrationSize * 0.85,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                            item.fallbackIcon,
                                            size: 80,
                                            color: AppColors.primary,
                                          ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: AppDimens.dimen28),

                          // Slide Title
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),

                          const SizedBox(height: AppDimens.dimen12),

                          // Slide Subtitle
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.dimen16,
                            ),
                            child: Text(
                              item.subtitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppDimens.dimen16),

              // Animated 3-Dots Page Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_tutorials.length, (index) {
                  final isActive = _currentPage == index;

                  return GestureDetector(
                    key: ValueKey('dot_$index'),
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.borderColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: AppDimens.dimen24),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: AppTextButton(
                  title: "Get Started",
                  borderRadius: AppDimens.dimen12,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  onPressed: () => context.go(AppRoutes.userName.path),
                ),
              ),

              const SizedBox(height: AppDimens.dimen12),
            ],
          ),
        ),
      ),
    );
  }
}
