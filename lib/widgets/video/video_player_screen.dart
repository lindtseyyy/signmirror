import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final VideoPlayerController _controller;
  late final Future<void> _initFuture;

  VideoPlayerController _createController(String url) {
    final raw = url.trim();
    final uri = Uri.tryParse(raw);

    if (uri != null) {
      final scheme = uri.scheme.toLowerCase();
      if (scheme == 'http' || scheme == 'https') {
        return VideoPlayerController.networkUrl(uri);
      }

      // Tolerate file:// URIs (e.g. file:///data/user/0/.../video.mp4)
      if (scheme == 'file') {
        return VideoPlayerController.file(File.fromUri(uri));
      }
    }

    // Absolute local file paths (e.g. /data/user/0/.../uploads/xxx.mp4)
    if (raw.startsWith('/')) {
      return VideoPlayerController.file(File(raw));
    }

    // Default: treat as an asset key/path.
    return VideoPlayerController.asset(raw);
  }

  @override
  void initState() {
    super.initState();

    _controller = _createController(widget.videoUrl);

    _initFuture = () async {
      await _controller.initialize().timeout(const Duration(seconds: 12));
      if (!mounted) return;
      await _controller.play();
    }();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _controller.value.isInitialized) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final aspectRatio = _controller.value.aspectRatio;
              final isPortraitVideo = aspectRatio < 1.0;

              final maxWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : MediaQuery.sizeOf(context).width;

              final maxHeight = constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : MediaQuery.sizeOf(context).height;

              if (maxWidth <= 0 || maxHeight <= 0) {
                return const SizedBox.shrink();
              }

              double targetWidth;
              double targetHeight;

              if (isPortraitVideo) {
                // Prefer fitting to available height (vertical fit)
                targetHeight = maxHeight;
                targetWidth = targetHeight * aspectRatio;

                if (targetWidth > maxWidth) {
                  targetWidth = maxWidth;
                  targetHeight = targetWidth / aspectRatio;
                }
              } else {
                // Prefer fitting to available width (horizontal fit)
                targetWidth = maxWidth;
                targetHeight = targetWidth / aspectRatio;

                if (targetHeight > maxHeight) {
                  targetHeight = maxHeight;
                  targetWidth = targetHeight * aspectRatio;
                }
              }

              return Center(
                child: SizedBox(
                  width: targetWidth,
                  height: targetHeight,
                  child: VideoPlayer(_controller),
                ),
              );
            },
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Error loading video",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
