import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intraflow/widgets/custom_app_bar_bottom_sheet.dart';

class CustomFullScreenImageWeb extends StatelessWidget {
  final String? imagePath;
  final Uint8List? imageData;

  const CustomFullScreenImageWeb({
    super.key,
    this.imagePath,
    this.imageData,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktopWeb = kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows);

    return Scaffold(
      appBar: const CustomAppBarBottomSheet(),
      body: Center(
        child: isDesktopWeb
            ? SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildImageWidgets(),
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildImageWidgets(),
                ),
              ),
      ),
    );
  }

  List<Widget> _buildImageWidgets() {
    return [
      if (imagePath != null)
        Image.network(
          imagePath!,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return SizedBox(
                width: 100,
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!.toDouble()
                        : null,
                  ),
                ),
              );
            }
          },
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error, color: Colors.red, size: 50),
        ),
      if (imageData != null) Image.memory(imageData!),
    ];
  }
}
