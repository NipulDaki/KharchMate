import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/helper/validation_helper.dart';
import 'package:kharch_mate/models/user_profile.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:kharch_mate/widgets/app_text_button.dart';
import 'package:kharch_mate/widgets/app_textformfield.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  late final DatabaseService _dbService;
  StreamSubscription<UserProfile>? _userProfileSubscription;
  UserProfile? _userProfile;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _dbService = serviceLocator<DatabaseService>();
    _loadUserProfile();
    _userProfileSubscription = _dbService.onUserProfileChanged.listen((
      profile,
    ) {
      if (mounted) {
        setState(() {
          _userProfile = profile;
        });
      }
    });
  }

  @override
  void dispose() {
    _userProfileSubscription?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await _dbService.getUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = user;
          _nameController.text = user?.name ?? '';
          _emailController.text = user?.email ?? '';
        });
      }
    } catch (_) {
      // Ignore load error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final enteredName = _nameController.text.trim();
    final enteredEmail = _emailController.text.trim();

    if (enteredName.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final updated = await _dbService.updateUserProfile(
        name: enteredName,
        email: enteredEmail.isNotEmpty ? enteredEmail : null,
      );

      if (mounted) {
        setState(() {
          _userProfile = updated;
          _nameController.text = updated.name;
          _emailController.text = updated.email ?? '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.income,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userInitials = _userProfile?.initials ?? 'U';
    final currencyDisplay =
        '${_userProfile?.currencyCode ?? 'INR'} (${_userProfile?.currencySymbol ?? '₹'})';
    final formattedCreatedAt = _userProfile?.createdAt != null
        ? DateFormat('MMMM d, yyyy').format(_userProfile!.createdAt)
        : 'N/A';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'User Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.dimen16,
                  vertical: AppDimens.dimen16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar and Top Summary Header
                      _buildAvatarCard(userInitials),

                      const SizedBox(height: AppDimens.dimen24),

                      // Section Title: Personal Details
                      _buildSectionTitle(
                        icon: Icons.badge_outlined,
                        title: 'Personal Details',
                      ),

                      const SizedBox(height: AppDimens.dimen12),

                      // Edit Profile Inputs Card
                      Container(
                        padding: const EdgeInsets.all(AppDimens.dimen16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Full Name Input
                            AppTextFormField(
                              controller: _nameController,
                              hintText: 'Enter your full name',
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                                color: AppColors.primary,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Name cannot be empty';
                                }
                                if (value.trim().length < 2) {
                                  return 'Name must be at least 2 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: AppDimens.dimen16),

                            // Email Address Input
                            AppTextFormField(
                              controller: _emailController,
                              hintText: 'Enter your email address',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _saveProfile(),
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: AppColors.primary,
                              ),
                              validator: ValidationHelper.email,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDimens.dimen24),

                      // Section Title: Account Information
                      _buildSectionTitle(
                        icon: Icons.info_outline_rounded,
                        title: 'Account Information',
                      ),

                      const SizedBox(height: AppDimens.dimen12),

                      // Account Details Card
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.dimen16,
                          vertical: AppDimens.dimen12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.currency_exchange_rounded,
                              label: 'Default Currency',
                              value: currencyDisplay,
                            ),
                            const Divider(
                              height: 1,
                              color: AppColors.dividerColor,
                            ),
                            _buildInfoRow(
                              icon: Icons.calendar_today_rounded,
                              label: 'Member Since',
                              value: formattedCreatedAt,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDimens.dimen32),

                      // Save Changes Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: _isSaving
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              )
                            : AppTextButton(
                                title: 'Save Changes',
                                borderRadius: AppDimens.dimen12,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                textStyle: theme.textTheme.titleMedium
                                    ?.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                onPressed: _saveProfile,
                              ),
                      ),

                      const SizedBox(height: AppDimens.dimen24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildAvatarCard(String initials) {
    final displayName = _userProfile?.name.trim().isNotEmpty == true
        ? _userProfile!.name
        : 'User Profile';
    final displayEmail = _userProfile?.email?.trim().isNotEmpty == true
        ? _userProfile!.email!
        : 'No email added';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.dimen20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.linerGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.dimen12),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayEmail,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimens.dimen10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.incomeLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: AppColors.income,
                ),
                SizedBox(width: 4),
                Text(
                  'Active Account',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.income,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4F8),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: AppColors.textPrimary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F4F8),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
