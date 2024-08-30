import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/views/pdf_screen_view.dart';
import 'package:intraflow/widgets/custom_full_screen_image.dart';
import 'package:intraflow/widgets/custom_full_screen_image_web.dart';
import 'package:intraflow/widgets/custom_relative_size_image.dart';
import 'package:intraflow/widgets/custom_snack_bar.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CustomPageView extends StatefulWidget {
  final List<dynamic> images;
  final List<String>? docIds;
  final List<String?>? pdfs;
  final List<String>? titles;
  final Function(int) onPageChanged;

  const CustomPageView({
    super.key,
    required this.images,
    this.docIds,
    this.pdfs,
    this.titles,
    required this.onPageChanged,
  });

  @override
  CustomPageViewState createState() => CustomPageViewState();
}

class CustomPageViewState extends State<CustomPageView> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _pageController.addListener(_pageListener);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: widget.onPageChanged,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      final pdfUrl =
                          widget.pdfs != null ? widget.pdfs![index] : null;
                      if (kIsWeb) {
                        if (pdfUrl == null || pdfUrl.isEmpty) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CustomFullScreenImageWeb(
                                imagePath: widget.images[index] as String,
                              ),
                            ),
                          );
                        } else {
                          _openPdfInBrowser(pdfUrl);
                        }
                      } else {
                        if (pdfUrl == null || pdfUrl.isEmpty) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CustomFullScreenImage(
                                imagePath: widget.images[index] as String,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PDFScreenView(
                                docId: widget.docIds != null
                                    ? widget.docIds![index]
                                    : '',
                                title: widget.titles != null
                                    ? widget.titles![index]
                                    : '',
                                fileUrl: pdfUrl,
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Stack(
                        children: [
                          if (widget.images[index] is String)
                            CustomRelativeSizeImage(
                              imageURL: widget.images[index] as String,
                            )
                          else if (widget.images[index] is Uint8List)
                            Image.memory(
                              widget.images[index] as Uint8List,
                              fit: BoxFit.cover,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (kIsWeb && widget.images.length > 1) ...[
                if (_currentPage > 0)
                  Positioned(
                    left: 0,
                    top: MediaQuery.of(context).size.height / 2 - 100,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: CustomColors.secondaryColor,
                      ),
                      onPressed: _goToPreviousPage,
                    ),
                  ),
                if (_currentPage < widget.images.length - 1)
                  Positioned(
                    right: 0,
                    top: MediaQuery.of(context).size.height / 2 - 100,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: CustomColors.secondaryColor,
                      ),
                      onPressed: _goToNextPage,
                    ),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        if (widget.images.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: _currentPage == index ? 12.0 : 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? CustomColors.secondaryColor
                        : CustomColors.tertiaryColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _pageListener() {
    setState(() {
      _currentPage = _pageController.page!.round();
    });
  }

  void _goToNextPage() {
    if (_currentPage < widget.images.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _openPdfInBrowser(String pdfUrl) async {
    await launchUrlString(pdfUrl).then((value) {
      if (value == false) {
        CustomSnackBar.showDefault(
          context,
          'Baixando PDF...',
        );
      } else {
        CustomSnackBar.showDefault(
          context,
          'Não foi possível fazer o download do PDF.',
        );
      }
    });
  }
}
