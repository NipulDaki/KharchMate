import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final String loadingText;
  final double size;
  final bool blockInteraction;
  final double width;
  final double? height;

  const AppLoader({
    super.key,
    this.loadingText = '',
    this.size = 20,
    this.blockInteraction = true,
    this.width = 100,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final loaderContent = Center(
      child: Container(
        width: width,
        constraints: BoxConstraints(
          minWidth: width,
          maxWidth: width,
          minHeight: height ?? (loadingText.isNotEmpty ? 100 : width),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: size,
              width: size,
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            if (loadingText.isNotEmpty) ...[
              const SizedBox(height: 12),

              Text(
                loadingText,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (!blockInteraction) {
      return loaderContent;
    }

    return AbsorbPointer(
      absorbing: true,
      child: Container(
        color: Colors.black.withValues(alpha: 0.3), // dim background
        child: loaderContent,
      ),
    );
  }
}
