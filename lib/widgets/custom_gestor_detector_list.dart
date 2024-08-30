import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intraflow/views/pdf_screen_view.dart';
import 'package:intraflow/widgets/custom_full_screen_image.dart';
import 'package:intraflow/widgets/custom_full_screen_image_web.dart';
import 'package:intraflow/widgets/custom_snack_bar.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CustomGestureDetectorList extends StatelessWidget {
  final String? imagePath;
  final Uint8List? imageData;
  final String? docID;
  final String? title;
  final String? pdfPath;
  final Widget child;

  const CustomGestureDetectorList({
    super.key,
    this.imagePath,
    this.imageData,
    this.docID,
    this.title,
    this.pdfPath,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (kIsWeb) {
          if (pdfPath != null && pdfPath!.isNotEmpty) {
            _openPdfInBrowser(context, pdfPath!);
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CustomFullScreenImageWeb(
                  imagePath: imagePath,
                  imageData: imageData,
                ),
              ),
            );
          }
        } else {
          if (pdfPath != null && pdfPath!.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PDFScreenView(
                  docId: docID ?? '',
                  title: title ?? '',
                  fileUrl: pdfPath!,
                ),
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CustomFullScreenImage(
                  imagePath: imagePath,
                  imageData: imageData,
                ),
              ),
            );
          }
        }
      },
      child: child,
    );
  }

  Future<void> _openPdfInBrowser(BuildContext context, String pdfUrl) async {
    await launchUrlString(pdfUrl).then((value) {
      ScaffoldMessenger.of(context).clearSnackBars();
      CustomSnackBar.showDefault(
        context,
        'Baixando pdf...',
      );
    });
  }
}
