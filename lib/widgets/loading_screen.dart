import 'package:flutter/material.dart';

class LoadingScreenWidget extends StatelessWidget {
  final String label;
  const LoadingScreenWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bool highContrast = MediaQuery.highContrastOf(context);
    final bool isDark = theme.brightness == Brightness.dark;

    // Use ColorScheme scrim, but tune opacity for readability and accessibility.
    double scrimOpacity = isDark ? 0.55 : 0.45;
    if (highContrast) scrimOpacity += 0.15;
    scrimOpacity = scrimOpacity.clamp(0.35, 0.85);

    final TextStyle labelStyle =
        (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
          color: colors.onSurface,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        );

    final BorderSide side = highContrast
        ? BorderSide(color: colors.outline, width: 1.5)
        : (isDark
              ? BorderSide.none
              : BorderSide(color: colors.outlineVariant, width: 1));

    return Stack(
      children: [
        // Modal-like barrier that blocks touches behind the loading UI.
        ModalBarrier(
          dismissible: false,
          color: colors.scrim.withOpacity(scrimOpacity),
        ),
        Center(
          child: Material(
            color: colors.surface,
            elevation: highContrast ? 0 : 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: side,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: colors.primary,
                    backgroundColor: colors.surface,
                  ),
                  const SizedBox(height: 14),
                  Text(label, style: labelStyle, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
