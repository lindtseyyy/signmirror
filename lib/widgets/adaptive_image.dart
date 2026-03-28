import 'package:flutter/material.dart';

class AdaptiveImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const AdaptiveImage(
    this.imagePath, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder ??
            (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
      );
    } else {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder ??
            (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
      );
    }
  }
}
