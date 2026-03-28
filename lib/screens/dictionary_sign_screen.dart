import 'package:flutter/material.dart';
import 'package:signmirror_flutter/models/sign.dart';
import 'package:signmirror_flutter/widgets/video/adaptive_video_player.dart';
import 'package:signmirror_flutter/widgets/adaptive_image.dart';

class DictionarySignScreen extends StatelessWidget {
  final Sign sign;

  const DictionarySignScreen({super.key, required this.sign});

  void _practiceSign(BuildContext context) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Starting real-time practice...')),
    // );
    // Implement actual practice logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sign.title),
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
                child: sign.videoUrl != null && sign.videoUrl!.isNotEmpty
                    ? AdaptiveVideoPlayer(videoUrl: sign.videoUrl!)
                    : AdaptiveImage(
                        sign.imagePath,
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
                sign.title,
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
                    sign.instructions ??
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

              // 3. Navigation Controls (Only Practice)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _practiceSign(context),
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: const Text(
                        "Practice",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff69B85E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
