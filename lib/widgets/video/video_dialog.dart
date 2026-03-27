import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:signmirror_flutter/widgets/video/video_player_screen.dart';

class VideoDialog extends StatelessWidget {
  final String videoUrl;
  const VideoDialog({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final maxDialogWidth = math.min(screen.width - 32.0, 720.0);
    final maxDialogHeight = math.min(
      screen.height - 48.0,
      screen.height * 0.85,
    );

    return Dialog(
      backgroundColor: Colors.white.withValues(alpha: 0.5),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxDialogWidth,
          maxHeight: maxDialogHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const closeRowHeight = 48.0;
              const spacing = 8.0;

              final usableHeight = constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : maxDialogHeight;

              final videoHeight = (usableHeight - closeRowHeight - spacing)
                  .clamp(0.0, usableHeight)
                  .toDouble();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: closeRowHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: spacing),
                  SizedBox(
                    height: videoHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ColoredBox(
                        color: Colors.black,
                        child: Center(
                          child: VideoPlayerScreen(videoUrl: videoUrl),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
