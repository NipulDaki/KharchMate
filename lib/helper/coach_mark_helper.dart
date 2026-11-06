import 'package:flutter/material.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';
import 'package:kharch_mate/services/secure_storage_service.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

/// Helper to create and display beautiful, interactive Coach Mark tutorials
/// across the key screens of KharchMate (Dashboard, Add Transaction, Add Category, Settings).
class CoachMarkHelper {
  CoachMarkHelper._();

  static TutorialCoachMark? _activeTutorial;
  static bool _isShowing = false;

  /// Safely dismisses and cleans up any currently visible coach mark overlay.
  static void dismissActiveTutorial() {
    if (_activeTutorial != null && _activeTutorial!.isShowing) {
      try {
        _activeTutorial!.finish();
      } catch (_) {}
    }
    _activeTutorial = null;
    _isShowing = false;
  }

  /// Creates a unified, branded [TargetFocus] for [TutorialCoachMark].
  static TargetFocus createTarget({
    required String identify,
    required GlobalKey keyTarget,
    required String title,
    required String description,
    required int stepIndex,
    required int totalSteps,
    IconData? icon,
    ContentAlign align = ContentAlign.bottom,
    ShapeLightFocus shape = ShapeLightFocus.RRect,
    double radius = 12.0,
    double paddingFocus = 6.0,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: keyTarget,
      shape: shape,
      radius: radius,
      paddingFocus: paddingFocus,
      contents: [
        TargetContent(
          align: align,
          builder: (context, controller) {
            final isLast = stepIndex == totalSteps;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.all(AppDimens.dimen16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step Badge & Skip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'STEP $stepIndex OF $totalSteps',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.skip(),
                        child: const Text(
                          'Skip Tour',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Title with Icon
                  Row(
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Description
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (stepIndex > 1) ...[
                        TextButton(
                          onPressed: () => controller.previous(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                          child: const Text(
                            'Previous',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      ElevatedButton(
                        onPressed: () {
                          if (isLast) {
                            controller.next();
                          } else {
                            controller.next();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          isLast ? 'Got it! ✓' : 'Next →',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// Checks if the coach mark for [storageKey] was already displayed.
  /// If not seen (or if [forceShow] is true), initializes and presents the tutorial.
  static Future<void> showTutorial({
    required BuildContext context,
    required List<TargetFocus> targets,
    required String storageKey,
    bool forceShow = false,
    VoidCallback? onFinish,
    VoidCallback? onSkip,
  }) async {
    if (targets.isEmpty) return;

    final storage = serviceLocator<SecureStorageService>();
    if (!forceShow) {
      final seen = await storage.hasSeenCoachMark(storageKey);
      if (seen) return;
    }

    // Immediately mark as seen so future redirects will NEVER show this again!
    if (!forceShow) {
      await storage.markCoachMarkSeen(storageKey);
    }

    if (!context.mounted) return;

    // Small delay ensuring all widgets are rendered and layout coordinates are ready
    await Future.delayed(const Duration(milliseconds: 350));
    if (!context.mounted) return;

    // Clean up any stale active tutorial overlay
    dismissActiveTutorial();

    if (_isShowing && !forceShow) return;
    _isShowing = true;

    final tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.75,
      paddingFocus: 8,
      hideSkip: true,
      onFinish: () async {
        _isShowing = false;
        _activeTutorial = null;
        await storage.markCoachMarkSeen(storageKey);
        onFinish?.call();
      },
      onSkip: () {
        _isShowing = false;
        _activeTutorial = null;
        storage.markCoachMarkSeen(storageKey);
        onSkip?.call();
        return true;
      },
    );

    _activeTutorial = tutorial;
    tutorial.show(context: context);
  }
}
