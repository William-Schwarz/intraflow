import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomRelativeSizeImage extends StatelessWidget {
  final String imageURL;

  const CustomRelativeSizeImage({
    super.key,
    required this.imageURL,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image(
        image: CachedNetworkImageProvider(
          imageURL,
          maxHeight: 800,
          maxWidth: 600,
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!.toDouble()
                    : null,
              ),
            );
          }
        },
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      ),
    );
  }
}
