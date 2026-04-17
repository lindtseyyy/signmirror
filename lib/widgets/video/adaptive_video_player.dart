import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:signmirror_flutter/widgets/adaptive_image.dart';

class AdaptiveVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailPath;

  const AdaptiveVideoPlayer({
    super.key,
    required this.videoUrl,
    this.thumbnailPath,
  });

  @override
  State<AdaptiveVideoPlayer> createState() => _AdaptiveVideoPlayerState();
}

class _AdaptiveVideoPlayerState extends State<AdaptiveVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  YoutubePlayerController? _youtubePlayerController;

  bool _isYoutube = false;
  bool _isInitialized = false;
  bool _hasError = false;

  // New state flag to track if the user has requested playback
  bool _userStarted = false;

  bool _repeatEnabled = false;
  double _playbackSpeed = 1.0;
  bool _youtubeFinished = false;

  @override
  void initState() {
    super.initState();
    // Do not initialize the player immediately to prevent lag.
    // Initialization happens when user taps play.
  }

  @override
  void didUpdateWidget(covariant AdaptiveVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeCurrentPlayer();
      // Reset user intent so new video shows thumbnail
      setState(() {
        _userStarted = false;
      });
    }
  }

  void _disposeCurrentPlayer() {
    _videoPlayerController?.dispose();
    _youtubePlayerController?.dispose();
    _videoPlayerController = null;
    _youtubePlayerController = null;
    _isYoutube = false;
    _isInitialized = false;
    _hasError = false;
    _youtubeFinished = false;
  }

  void _startPlayback() {
    setState(() {
      _userStarted = true;
      _hasError = false;
      _youtubeFinished = false;
    });
    _initializePlayer();
  }

  Future<void> _toggleRepeat() async {
    final newValue = !_repeatEnabled;
    setState(() {
      _repeatEnabled = newValue;
    });

    final videoController = _videoPlayerController;
    if (!_isYoutube && videoController != null) {
      try {
        await videoController.setLooping(newValue);
        final value = videoController.value;
        final isFinished =
            value.isInitialized &&
            value.duration.inMilliseconds > 0 &&
            value.position >= value.duration &&
            !value.isPlaying;
        if (newValue && isFinished) {
          await videoController.seekTo(Duration.zero);
          await videoController.play();
        }
      } catch (_) {
        // Best-effort: ignore if controller is in a bad state.
      }
      return;
    }

    final youtubeController = _youtubePlayerController;
    if (_isYoutube && youtubeController != null) {
      if (newValue && _youtubeFinished) {
        setState(() => _youtubeFinished = false);
        try {
          youtubeController.seekTo(Duration.zero);
          youtubeController.play();
        } catch (_) {
          // Ignore; controller can be transient while initializing.
        }
      }
    }
  }

  Future<void> _setPlaybackSpeed(double speed) async {
    setState(() {
      _playbackSpeed = speed;
    });

    final videoController = _videoPlayerController;
    if (!_isYoutube && videoController != null) {
      try {
        await videoController.setPlaybackSpeed(speed);
      } catch (_) {
        // Ignore if controller is not ready.
      }
    }
  }

  void _initializePlayer() {
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId != null) {
      _isYoutube = true;
      _youtubePlayerController =
          YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay:
                  true, // Auto-play is true because we only initialize when user taps play
              loop: false,
              hideControls: false,
            ),
          )..addListener(() {
            if (_youtubePlayerController?.value.hasError ?? false) {
              if (mounted && !_hasError) {
                setState(() => _hasError = true);
              }
            }
          });
      // Delay initialization state slightly to ensure controller is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isInitialized = true);
      });
    } else {
      _isYoutube = false;
      final uri = Uri.tryParse(widget.videoUrl);
      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        _videoPlayerController = VideoPlayerController.networkUrl(uri);
      } else {
        _videoPlayerController = VideoPlayerController.asset(widget.videoUrl);
      }

      _videoPlayerController!
          .initialize()
          .then((_) {
            if (!mounted) return;
            setState(() {
              _isInitialized = true;
            });
            _videoPlayerController!.setLooping(_repeatEnabled);
            _videoPlayerController!.setPlaybackSpeed(_playbackSpeed);
            _videoPlayerController!.play();
          })
          .catchError((error) {
            if (!mounted) return;
            setState(() {
              _hasError = true;
            });
          });
    }
  }

  @override
  void dispose() {
    _disposeCurrentPlayer();
    super.dispose();
  }

  Widget _buildThumbnail() {
    Widget thumbnailImage;
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    if (widget.thumbnailPath != null) {
      thumbnailImage = AdaptiveImage(
        widget.thumbnailPath!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (videoId != null) {
      thumbnailImage = Image.network(
        'https://img.youtube.com/vi/$videoId/sddefault.jpg',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.black12,
          width: double.infinity,
          height: double.infinity,
          child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
        ),
      );
    } else {
      // Fallback
      thumbnailImage = Container(
        color: Colors.black12,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        thumbnailImage,
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white70,
          child: IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.black, size: 40),
            padding: EdgeInsets.zero,
            onPressed: _startPlayback,
          ),
        ),
        // Allows tapping anywhere on the thumbnail to play
        Positioned.fill(child: GestureDetector(onTap: _startPlayback)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!_userStarted) {
      return _buildThumbnail();
    }

    if (_hasError) {
      return Stack(
        alignment: Alignment.center,
        children: [
          _buildThumbnail(),
          const Positioned.fill(child: ColoredBox(color: Colors.black54)),
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, color: Colors.redAccent, size: 50),
              SizedBox(height: 10),
              Text(
                'Error playing video',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      );
    }

    if (!_isInitialized) {
      return Stack(
        alignment: Alignment.center,
        children: [
          _buildThumbnail(),
          const Positioned.fill(child: ColoredBox(color: Colors.black54)),
          const CircularProgressIndicator(color: Colors.white),
        ],
      );
    }

    if (_isYoutube && _youtubePlayerController != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          YoutubePlayer(
            controller: _youtubePlayerController!,
            showVideoProgressIndicator: true,
            onEnded: (metaData) {
              if (_repeatEnabled) {
                try {
                  _youtubePlayerController!.seekTo(Duration.zero);
                  _youtubePlayerController!.play();
                } catch (_) {}
              } else {
                if (mounted) setState(() => _youtubeFinished = true);
              }
            },
            bottomActions: [
              CurrentPosition(),
              ProgressBar(isExpanded: true),
              IconButton(
                tooltip: _repeatEnabled ? 'Repeat on' : 'Repeat off',
                onPressed: _toggleRepeat,
                icon: Icon(
                  _repeatEnabled ? Icons.repeat_one : Icons.repeat,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 10),
              RemainingDuration(),
              const PlaybackSpeedButton(),
            ],
          ),
          if (_youtubeFinished && !_repeatEnabled)
            CircleAvatar(
              radius: 30,
              backgroundColor: colorScheme.scrim.withOpacity(0.6),
              child: IconButton(
                icon: Icon(
                  Icons.replay,
                  color: colorScheme.onSurface,
                  size: 30,
                ),
                onPressed: () {
                  setState(() => _youtubeFinished = false);
                  try {
                    _youtubePlayerController!.seekTo(Duration.zero);
                    _youtubePlayerController!.play();
                  } catch (_) {}
                },
              ),
            ),
        ],
      );
    }

    if (!_isYoutube && _videoPlayerController != null) {
      return ValueListenableBuilder(
        valueListenable: _videoPlayerController!,
        builder: (context, VideoPlayerValue value, child) {
          final isFinished =
              value.isInitialized &&
              value.duration.inMilliseconds > 0 &&
              value.position >= value.duration &&
              !value.isPlaying;

          final isPlaying = value.isPlaying;

          final progressColors = VideoProgressColors(
            playedColor: colorScheme.primary,
            bufferedColor: colorScheme.primary.withOpacity(0.35),
            backgroundColor: colorScheme.onSurface.withOpacity(0.2),
          );

          return Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: value.isInitialized && value.aspectRatio > 0
                    ? value.aspectRatio
                    : 16 / 9,
                child: VideoPlayer(_videoPlayerController!),
              ),

              // Tap region (doesn't cover the progress bar area)
              Positioned.fill(
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (isFinished && !_repeatEnabled) return;
                                if (isPlaying) {
                                  _videoPlayerController!.pause();
                                } else {
                                  _videoPlayerController!.play();
                                }
                              },
                            ),
                          ),
                          if (isFinished && !_repeatEnabled)
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: colorScheme.scrim.withOpacity(
                                0.6,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.replay,
                                  color: colorScheme.onSurface,
                                  size: 30,
                                ),
                                onPressed: () {
                                  _videoPlayerController!.seekTo(Duration.zero);
                                  _videoPlayerController!.play();
                                },
                              ),
                            )
                          else if (!isPlaying)
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: colorScheme.scrim.withOpacity(
                                0.6,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.play_arrow,
                                  color: colorScheme.onSurface,
                                  size: 30,
                                ),
                                onPressed: () {
                                  _videoPlayerController!.play();
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Bottom controls (progress + repeat + speed)
                    Container(
                      color: colorScheme.surface.withOpacity(0.65),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          VideoProgressIndicator(
                            _videoPlayerController!,
                            allowScrubbing: true,
                            colors: progressColors,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          Row(
                            children: [
                              IconButton(
                                tooltip: _repeatEnabled
                                    ? 'Repeat on'
                                    : 'Repeat off',
                                onPressed: _toggleRepeat,
                                icon: Icon(
                                  _repeatEnabled
                                      ? Icons.repeat_one
                                      : Icons.repeat,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              PopupMenuButton<double>(
                                tooltip: 'Playback speed',
                                initialValue: _playbackSpeed,
                                onSelected: (speed) => _setPlaybackSpeed(speed),
                                itemBuilder: (context) {
                                  const speeds = <double>[
                                    0.5,
                                    0.75,
                                    1.0,
                                    1.25,
                                    1.5,
                                    2.0,
                                  ];
                                  return speeds
                                      .map(
                                        (s) => PopupMenuItem<double>(
                                          value: s,
                                          child: Text(
                                            '${s.toStringAsFixed(s == 1.0 ? 0 : 2)}x',
                                          ),
                                        ),
                                      )
                                      .toList();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.speed,
                                      color: colorScheme.onSurface,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${_playbackSpeed.toStringAsFixed(_playbackSpeed == 1.0 ? 0 : 2)}x',
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: colorScheme.onSurface,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}
