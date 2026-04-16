import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum SnackBarPosition { top, bottom }

class SnackBarUtils {
  static const Duration _defaultDuration = Duration(milliseconds: 1400);
  static OverlayEntry? _topEntry;
  static int _topEntryToken = 0;

  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    SnackBarPosition position = SnackBarPosition.bottom,
    Duration duration = _defaultDuration,
    bool dismissKeyboard = false,
  }) {
    if (dismissKeyboard) {
      FocusManager.instance.primaryFocus?.unfocus();
    }

    // Avoid calling overlay/snackbar APIs during an active build/layout pass.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      if (position == SnackBarPosition.top) {
        _showTopOverlay(
          context,
          message: message,
          isError: isError,
          duration: duration,
        );
      } else {
        _showBottomSnackBar(
          context,
          message: message,
          isError: isError,
          duration: duration,
        );
      }
    });
  }

  static void _showBottomSnackBar(
    BuildContext context, {
    required String message,
    required bool isError,
    required Duration duration,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    // Remove immediately to avoid stacking/animations fighting each other.
    messenger.removeCurrentSnackBar();

    // Use the platform view insets so keyboard is respected even if this context
    // is under a Scaffold that removed viewInsets for its body.
    final media = MediaQueryData.fromView(View.of(context));
    final keyboardInset = media.viewInsets.bottom;

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: EdgeInsets.fromLTRB(20, 0, 20, 20 + keyboardInset),
      ),
    );
  }

  static void _runOverlayMutation(VoidCallback mutation) {
    final phase = WidgetsBinding.instance.schedulerPhase;

    // Overlay insert/remove ultimately marks the overlay for rebuild.
    // If this happens during build/layout, it can trigger exceptions or jank.
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      mutation();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => mutation());
    }
  }

  static void _safeRemoveOverlayEntry(OverlayEntry entry) {
    if (!entry.mounted) return;
    try {
      entry.remove();
    } catch (_) {
      // Ignore: can happen if the entry was already removed or the overlay is gone.
    }
  }

  static void _dismissTopOverlay({
    required int token,
    required OverlayEntry entry,
  }) {
    if (_topEntryToken != token) return;
    if (_topEntry != entry) return;

    _topEntry = null;
    _runOverlayMutation(() => _safeRemoveOverlayEntry(entry));
  }

  static void _showTopOverlay(
    BuildContext context, {
    required String message,
    required bool isError,
    required Duration duration,
  }) {
    _topEntryToken++;
    final token = _topEntryToken;

    final overlayState = Overlay.of(context, rootOverlay: true);
    if (overlayState == null) return;

    // Remove any existing entry safely (never during build/layout).
    final previous = _topEntry;
    _topEntry = null;
    if (previous != null) {
      _runOverlayMutation(() => _safeRemoveOverlayEntry(previous));
    }

    // Capture a fixed top inset that does NOT react to keyboard/viewInsets changes.
    // (Using viewPadding avoids viewInsets-driven changes during keyboard animation.)
    final fixedTopInset = MediaQueryData.fromView(
      View.of(context),
    ).viewPadding.top;

    final bgColor = isError ? Colors.redAccent : Colors.green;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) {
        return Positioned(
          top: fixedTopInset,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: GestureDetector(
              onTap: () => _dismissTopOverlay(token: token, entry: entry),
              child: Material(
                color: bgColor,
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    _topEntry = entry;

    // Insert safely (never during build/layout) and only if still current.
    _runOverlayMutation(() {
      if (_topEntryToken != token) return;
      if (_topEntry != entry) return;
      if (!overlayState.mounted) return;
      overlayState.insert(entry);
    });

    Future.delayed(
      duration,
    ).then((_) => _dismissTopOverlay(token: token, entry: entry));
  }
}
