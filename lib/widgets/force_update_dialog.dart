import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/extension/theme_extension.dart';
import 'package:kharch_mate/resources/app_dimension.dart';
import 'package:kharch_mate/services/app_update_service.dart';

/// A non-dismissible modal dialog informing the user that an update is required
/// on the Google Play Store to continue using the application.
class ForceUpdateDialog extends StatefulWidget {
  const ForceUpdateDialog({super.key});

  @override
  State<ForceUpdateDialog> createState() => _ForceUpdateDialogState();
}

class _ForceUpdateDialogState extends State<ForceUpdateDialog> {
  bool _isLoading = false;

  Future<void> _handleUpdate() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      if (serviceLocator.isRegistered<AppUpdateService>()) {
        final updateService = serviceLocator<AppUpdateService>();
        final result = await updateService.performImmediateUpdate();

        // If in-app update is not completed or was cancelled/failed, redirect to Play Store
        if (result != AppUpdateResult.success) {
          await updateService.openPlayStore();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleExit() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: context.colors.cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.dimen20),
        ),
        contentPadding: const EdgeInsets.fromLTRB(
          AppDimens.dimen24,
          AppDimens.dimen24,
          AppDimens.dimen24,
          AppDimens.dimen16,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.system_update_rounded,
                size: 34,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: AppDimens.dimen16),
            Text(
              'Update Required',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimens.dimen8),
            Text(
              'A newer version of KharchMate is available on Google Play. Please update to continue tracking your expenses seamlessly.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppDimens.dimen24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleExit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.textSecondary,
                      side: BorderSide(
                        color: context.colors.cardBorder,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimens.dimen12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.dimen12),
                      ),
                    ),
                    child: const Text('Exit App'),
                  ),
                ),
                const SizedBox(width: AppDimens.dimen12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimens.dimen12,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.dimen12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Update Now',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
