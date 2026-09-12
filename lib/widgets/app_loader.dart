import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final String loadingText;
  final double size;
  final bool blockInteraction;

  const AppLoader({
    super.key,
    this.loadingText = '',
    this.size = 20,
    this.blockInteraction = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final loaderContent = Center(
      child: Container(
        width: 80,
        height: 80,
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                height: size,
                width: size,
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
            if (loadingText.isNotEmpty) ...[
              const SizedBox(height: 20),

              Text(
                loadingText,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
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
        color: Colors.black.withOpacity(0.3), // dim background
        child: loaderContent,
      ),
    );
  }
}
