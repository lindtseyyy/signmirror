import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';

class VideoThumbnailWidget extends StatelessWidget {
  final String videoUrl;

  const VideoThumbnailWidget({super.key, required this.videoUrl});

  Future<String?> _getThumbnail() async {
    // This creates a temp file on the phone to store the image
    final uint8list = await VideoThumbnail.thumbnailFile(
      video: videoUrl,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 200, // Quality control
      quality: 75,
    );
    return uint8list;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getThumbnail(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Image.file(File(snapshot.data!), fit: BoxFit.cover);
        }
        // Shimmer or loading color while generating
        return Container(
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
