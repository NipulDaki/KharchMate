import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:kharch_mate/widgets/force_update_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service responsible for managing Google Play In-App Updates and store redirection.
class AppUpdateService {
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.nipuldaki.kharchamate';
  static const String playStoreMarketUrl =
      'market://details?id=com.nipuldaki.kharchamate';

  bool _isUpdateInProgress = false;

  /// Whether an update flow or prompt is currently active.
  bool get isUpdateInProgress => _isUpdateInProgress;

  /// Checks for available Google Play update and starts immediate update if allowed.
  ///
  /// Returns:
  /// - [AppUpdateResult.success] if update succeeded or was handled.
  /// - [AppUpdateResult.userDeniedUpdate] if user declined the immediate update prompt.
  /// - [AppUpdateResult.inAppUpdateFailed] if the update flow encountered an error.
  /// - `null` if no update is available or running on non-Android platform.
  Future<AppUpdateResult?> checkForImmediateUpdate() async {
    if (!Platform.isAndroid) return null;

    try {
      final info = await InAppUpdate.checkForUpdate();

      // If an immediate update is already in progress, resume it
      if (info.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress) {
        _isUpdateInProgress = true;
        final result = await InAppUpdate.performImmediateUpdate();
        return result;
      }

      // Check if update is available and immediate update is allowed
      if (info.updateAvailability == UpdateAvailability.updateAvailable &&
          info.immediateUpdateAllowed) {
        _isUpdateInProgress = true;
        final result = await InAppUpdate.performImmediateUpdate();
        return result;
      }
    } catch (e) {
      debugPrint('AppUpdateService.checkForImmediateUpdate: $e');
    } finally {
      _isUpdateInProgress = false;
    }
    return null;
  }

  /// Resumes an immediate update if one was already triggered and is in progress.
  Future<void> resumeUpdateIfInProgress() async {
    if (!Platform.isAndroid) return;

    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress) {
        _isUpdateInProgress = true;
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      debugPrint('AppUpdateService.resumeUpdateIfInProgress: $e');
    } finally {
      _isUpdateInProgress = false;
    }
  }

  /// Triggers the immediate update flow directly.
  Future<AppUpdateResult> performImmediateUpdate() async {
    if (!Platform.isAndroid) return AppUpdateResult.inAppUpdateFailed;

    try {
      _isUpdateInProgress = true;
      final result = await InAppUpdate.performImmediateUpdate();
      return result;
    } catch (e) {
      debugPrint('AppUpdateService.performImmediateUpdate: $e');
      return AppUpdateResult.inAppUpdateFailed;
    } finally {
      _isUpdateInProgress = false;
    }
  }

  /// Opens the KharchMate app page directly on the Google Play Store.
  Future<bool> openPlayStore() async {
    final marketUri = Uri.parse(playStoreMarketUrl);
    final webUri = Uri.parse(playStoreUrl);

    try {
      final launched = await launchUrl(
        marketUri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;
    } catch (_) {}

    try {
      return await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('AppUpdateService.openPlayStore: $e');
      return false;
    }
  }

  /// Shows the non-dismissible force update dialog.
  Future<void> showForceUpdateDialog(BuildContext context) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const ForceUpdateDialog(),
    );
  }
}
