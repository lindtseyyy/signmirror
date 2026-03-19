import 'package:flutter/material.dart';

enum SnackBarPosition { top, bottom }

class SnackBarUtils {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    SnackBarPosition position = SnackBarPosition.bottom,
  }) {
    // Determine the margin based on position
    final isTop = position == SnackBarPosition.top;

    // Get screen height for the "top" hack if needed
    final double topPadding = MediaQuery.of(context).padding.top;
    final double screenHeight = MediaQuery.of(context).size.height;

    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Dismiss previous

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
        margin: isTop
            ? EdgeInsets.only(
                bottom:
                    screenHeight -
                    (topPadding + 80), // Adjusted for typical app bars
                left: 20,
                right: 20,
              )
            : const EdgeInsets.all(20),
      ),
    );
  }
}
