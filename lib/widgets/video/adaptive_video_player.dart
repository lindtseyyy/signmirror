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
  }

  void _startPlayback() {
    setState(() {
      _userStarted = true;
      _hasError = false;
    });
    _initializePlayer();
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
      return YoutubePlayer(
        controller: _youtubePlayerController!,
        showVideoProgressIndicator: true,
        bottomActions: [
          CurrentPosition(),
          ProgressBar(isExpanded: true),
          const SizedBox(width: 10),
          RemainingDuration(),
          const PlaybackSpeedButton(),
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
              value.position >= value.duration;

          final isPlaying = value.isPlaying;

          return Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: value.isInitialized && value.aspectRatio > 0
                    ? value.aspectRatio
                    : 16 / 9,
                child: VideoPlayer(_videoPlayerController!),
              ),

              if (isFinished)
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(
                      Icons.replay,
                      color: Colors.white,
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
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      _videoPlayerController!.play();
                    },
                  ),
                ),

              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    if (isFinished) return;
                    if (isPlaying) {
                      _videoPlayerController!.pause();
                    } else {
                      _videoPlayerController!.play();
                    }
                  },
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
