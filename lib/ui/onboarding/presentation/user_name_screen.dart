import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/helper/validation_helper.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';
import 'package:kharch_mate/router/app_routes.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:kharch_mate/widgets/app_text_button.dart';
import 'package:kharch_mate/widgets/app_textformfield.dart';

class UserNameScreen extends StatefulWidget {
  const UserNameScreen({super.key});

  @override
  State<UserNameScreen> createState() => _UserNameScreenState();
}

class _UserNameScreenState extends State<UserNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitUser() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final enteredName = _nameController.text.trim();
    final enteredEmail = _emailController.text.trim();
    if (enteredName.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final dbService = serviceLocator<DatabaseService>();
      await dbService.saveUserName(
        enteredName,
        email: enteredEmail.isNotEmpty ? enteredEmail : null,
      );

      if (mounted) {
        context.go(AppRoutes.dashboard.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save user: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.dimen24,
                vertical: AppDimens.dimen20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimens.dimen20),

                    // Brand Icon / Avatar Badge
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.linerGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 44,
                          color: AppColors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimens.dimen36),

                    // Heading
                    Text(
                      "What should we\ncall you? 👋",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: AppDimens.dimen12),

                    // Subtitle
                    Text(
                      "Enter your name and email to personalize your financial dashboard and track your kharch effortlessly.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: AppDimens.dimen32),

                    // Name Input
                    AppTextFormField(
                      controller: _nameController,
                      hintText: "Your Full Name",
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.primary,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name to continue';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppDimens.dimen20),

                    // Email Input
                    AppTextFormField(
                      controller: _emailController,
                      hintText: "Your Email Address",
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submitUser(),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.primary,
                      ),
                      validator: ValidationHelper.email,
                    ),

                    const SizedBox(height: AppDimens.dimen36),

                    // Continue Button
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
                        onPressed: _isLoading ? null : _submitUser,
                      ),
                    ),

                    const SizedBox(height: AppDimens.dimen24),

                    Center(
                      child: Text(
                        "🔒 100% Offline & Private • Stored securely on device",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
