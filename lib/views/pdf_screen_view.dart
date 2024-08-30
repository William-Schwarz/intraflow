import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intraflow/controllers/files_controller.dart';
import 'package:intraflow/widgets/custom_app_bar.dart';
import 'package:intraflow/widgets/custom_elevated_button_icon.dart';
import 'package:intraflow/widgets/custom_screen_download.dart';

class PDFScreenView extends StatefulWidget {
  final String? docId;
  final String title;
  final String? fileUrl;
  final File? file;

  const PDFScreenView({
    super.key,
    this.docId,
    required this.title,
    this.fileUrl,
    this.file,
  });

  @override
  PDFScreenViewState createState() => PDFScreenViewState();
}

class PDFScreenViewState extends State<PDFScreenView> {
  late Future<File?> _futureFile;
  String? errorMessage;
  final FilesController _filesController = FilesController();

  @override
  void initState() {
    super.initState();
    _futureFile = _getFile();
  }

  Future<File?> _getFile() async {
    try {
      if (widget.file != null) {
        return widget.file!;
      } else if (widget.fileUrl != null) {
        return await _filesController.getFile(
          url: widget.fileUrl!,
          firebaseDocId: widget.docId!,
        );
      } else {
        throw Exception('Nenhum arquivo ou URL fornecido');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Revista K Entre Nós',
        leadingVisible: true,
      ),
      body: FutureBuilder<File?>(
        future: _futureFile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError || snapshot.data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: SvgPicture.asset(
                        'assets/images/svgs/cancel_485156.svg',
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Erro ao carregar o arquivo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomElevatedButtonIcon(
                      onPressed: () {
                        setState(() {
                          _futureFile = _getFile();
                        });
                      },
                      icon: Icons.replay_outlined,
                      label: 'Tentar Novamente',
                    ),
                  ],
                ),
              );
            }
            return PDFView(
              filePath: snapshot.data!.path,
              autoSpacing: true,
              swipeHorizontal: true,
              pageFling: true,
              onRender: (pages) {
                if (kDebugMode) {
                  print("Número de páginas: $pages");
                }
              },
              onError: (error) {
                setState(() {
                  errorMessage = error.toString();
                });
                if (kDebugMode) {
                  print(error.toString());
                }
              },
              onPageError: (page, error) {
                setState(() {
                  errorMessage = 'Erro na página $page: ${error.toString()}';
                });
                if (kDebugMode) {
                  print('$page: ${error.toString()}');
                }
              },
              onViewCreated: (PDFViewController pdfViewController) {
                if (kDebugMode) {
                  print("PDF View Criado");
                }
              },
              onPageChanged: (int? page, int? total) {
                if (kDebugMode) {
                  print('Página atual: $page de $total');
                }
              },
            );
          } else {
            return const CustomScreenDownload();
          }
        },
      ),
    );
  }
}
