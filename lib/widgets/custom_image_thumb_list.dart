import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomImageThumbList extends StatelessWidget {
  final String thumbURL;

  const CustomImageThumbList({
    Key? key,
    required this.thumbURL,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image(
        fit: BoxFit.cover,
        image: CachedNetworkImageProvider(
          thumbURL,
          maxHeight: 50,
          maxWidth: 50,
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!.toDouble()
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
