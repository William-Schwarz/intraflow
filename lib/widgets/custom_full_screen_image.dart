import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomFullScreenImage extends StatelessWidget {
  final String? imagePath;
  final Uint8List? imageData;

  const CustomFullScreenImage({
    Key? key,
    this.imagePath,
    this.imageData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(20.0),
            clipBehavior: Clip.none,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (imagePath != null)
                    Image.network(
                      imagePath!,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                        .toDouble()
                                : null,
                          );
                        }
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    ),
                  if (imageData != null) Image.memory(imageData!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
