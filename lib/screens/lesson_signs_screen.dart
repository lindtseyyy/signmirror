import 'package:signmirror_flutter/widgets/video/adaptive_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/models/lesson.dart';
import 'package:signmirror_flutter/models/sign.dart';
import 'package:signmirror_flutter/providers/providers.dart';
import 'package:signmirror_flutter/widgets/adaptive_image.dart';
import 'package:signmirror_flutter/screens/practice_mirror_screen.dart';

class LessonSignsScreen extends ConsumerStatefulWidget {
  final Lesson? lesson;

  const LessonSignsScreen({super.key, this.lesson});

  @override
  ConsumerState<LessonSignsScreen> createState() => _LessonSignsScreenState();
}

class _LessonSignsScreenState extends ConsumerState<LessonSignsScreen> {
  int currentIndex = 0;
  List<Sign> signs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSigns();
  }

  Future<void> _loadSigns() async {
    if (widget.lesson != null) {
      final isarService = ref.read(isarServiceProvider);
      final loadedSigns = await isarService.getSignsByCategory(
        widget.lesson!.title,
      );
      setState(() {
        signs = loadedSigns;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _nextSign() {
    if (currentIndex < signs.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void _prevSign() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  void _practiceSign(Sign sign) {
    final referenceVideoUrl =
        (sign.videoUrl != null && sign.videoUrl!.isNotEmpty)
        ? sign.videoUrl!
        : 'assets/videos/sample_portrait_video.mp4';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PracticeMirrorScreen(
          referenceVideoUrl: referenceVideoUrl,
          targetGestureName: sign.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (signs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.lesson?.title ?? "Lesson")),
        body: const Center(child: Text("No signs available for this lesson.")),
      );
    }

    final currentSign = signs[currentIndex];
    final hasNext = currentIndex < signs.length - 1;
    final hasPrev = currentIndex > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson?.title ?? "Lesson"),
        backgroundColor: const Color(0xff304166),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. "Video" Section
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(15),
                ),
                clipBehavior: Clip.hardEdge,
                child:
                    currentSign.videoUrl != null &&
                        currentSign.videoUrl!.isNotEmpty
                    ? AdaptiveVideoPlayer(videoUrl: currentSign.videoUrl!)
                    : AdaptiveImage(
                        currentSign.imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                      ),
              ),
              const SizedBox(height: 20),

              // 2. Sign Title & Instructions
              Text(
                currentSign.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    currentSign.instructions ??
                        "Follow the hand gesture shown in the visual above. Make sure your hand gestures are clear and recognizable.",
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // 3. Navigation Controls
              Row(
                children: [
                  // Previous Button
                  Expanded(
                    child: Visibility(
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      visible: hasPrev,
                      child: ElevatedButton.icon(
                        onPressed: _prevSign,
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text(
                          "Prev",
                          style: TextStyle(
                            fontSize: 13,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 12,
                          ),
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Practice Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _practiceSign(currentSign),
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: const Text(
                        "Practice",
                        style: TextStyle(
                          fontSize: 13,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff69B85E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Next Button
                  Expanded(
                    child: Visibility(
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      visible: hasNext,
                      child: ElevatedButton(
                        onPressed: _nextSign,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 12,
                          ),
                          backgroundColor: const Color(0xff304166),
                          foregroundColor: Colors.white,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Flexible(
                              child: Text(
                                "Next",
                                style: TextStyle(
                                  fontSize: 13,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Progress Indicator
              Center(
                child: Text(
                  "Sign ${currentIndex + 1} of ${signs.length}",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
