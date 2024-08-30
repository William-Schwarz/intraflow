import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomImageThumbPage extends StatelessWidget {
  final String thumbURL;

  const CustomImageThumbPage({
    super.key,
    required this.thumbURL,
  });

  @override
  Widget build(BuildContext context) {
    // debugInvertOversizedImages = true;
    return Image(
      fit: BoxFit.cover,
      image: CachedNetworkImageProvider(
        thumbURL,
        maxWidth: 200,
        maxHeight: 250,
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!.toDouble()
                : null,
          );
        }
      },
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
    );
  }
}
