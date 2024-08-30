import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intraflow/controllers/files_controller.dart';
import 'package:intraflow/controllers/lgpd_controller.dart';
import 'package:intraflow/models/lgpd_model.dart';
import 'package:intraflow/utils/helpers/app_config.dart';
import 'package:intraflow/views/lists/release_week/list_view_released_week.dart';
import 'package:intraflow/views/pdf_screen_view.dart';
import 'package:intraflow/widgets/custom_elevated_button_icon.dart';
import 'package:intraflow/widgets/custom_elevated_button_list.dart';
import 'package:intraflow/widgets/custom_gestor_detector_list.dart';
import 'package:intraflow/widgets/custom_saving_screen_upload.dart';
import 'package:intraflow/widgets/custom_snack_bar.dart';
import 'package:intraflow/widgets/custom_text_field.dart';

class UploadPDFLGPDView extends StatefulWidget {
  final LgpdController lgpdController;
  final FilesController filesController;
  final TextEditingController descricaoController;

  final void Function(BuildContext) post;
  final Future<void> Function() toggleShowListView;
  final bool showListView;
  final bool isLoading;
  final Future<List<LgpdModel>>? dataFuture;
  const UploadPDFLGPDView({
    super.key,
    required this.lgpdController,
    required this.filesController,
    required this.descricaoController,
    required this.post,
    required this.toggleShowListView,
    required this.showListView,
    required this.isLoading,
    this.dataFuture,
  });

  @override
  State<UploadPDFLGPDView> createState() => _UploadPDFLGPDViewState();
}

class _UploadPDFLGPDViewState extends State<UploadPDFLGPDView> {
  GlobalKey buttonKeyPDF = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.height *
                AppConfig().widhtMediaQueryWebPage!,
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: widget.descricaoController,
                  labelText: 'Descrição da Privacidade e Segurança',
                  hintText: 'Ex: K Entre Nós',
                  maxLength: 50,
                ),
                const SizedBox(height: 16),
                if (widget.lgpdController.pdfInfo != null)
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: widget.lgpdController.imageData != null
                          ? CustomGestureDetectorList(
                              imageData: widget.lgpdController.imageData,
                              child: Image.memory(
                                widget.lgpdController.imageData!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : null,
                      title: Text(
                        'Arquivo: ${widget.lgpdController.pdfInfo!.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Tamanho: ${(widget.lgpdController.pdfInfo!.size / 1024).toStringAsFixed(2)} KB',
                      ),
                      trailing: Visibility(
                        visible: (!kIsWeb),
                        child: IconButton(
                          icon: const Icon(Icons.search, size: 32),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PDFScreenView(
                                  title: widget.lgpdController.pdfInfo!.name,
                                  file: widget.lgpdController.pdfInfo!.file!,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  children: [
                    if (widget.lgpdController.pdfInfo != null)
                      CustomElevatedButtonIcon(
                        onPressed: () {
                          setState(() {
                            widget.lgpdController.pdfInfo = null;
                          });
                        },
                        icon: Icons.picture_as_pdf,
                        label: 'Remover',
                      )
                    else
                      CustomElevatedButtonIcon(
                        onPressed: () async {
                          await widget.lgpdController
                              .pickPDF()
                              .catchError((error) {
                            CustomSnackBar.showDefault(
                              context,
                              'Erro ao selecionar arquivo: ${error.toString()}',
                            );
                          }).whenComplete(() {
                            setState(() {});
                          });
                        },
                        icon: Icons.upload,
                        label: 'Carregar PDF',
                      ),
                    const SizedBox(width: 8),
                    Visibility(
                      visible: widget.lgpdController.pdfInfo != null,
                      child: widget.lgpdController.imageData != null
                          ? CustomElevatedButtonIcon(
                              onPressed: () {
                                setState(() {
                                  widget.lgpdController.imageData = null;
                                });
                              },
                              icon: Icons.image,
                              label: 'Remover',
                            )
                          : CustomElevatedButtonIcon(
                              onPressed: () async {
                                await widget.lgpdController
                                    .pickImage()
                                    .catchError((error) {
                                  CustomSnackBar.showDefault(
                                    context,
                                    'Erro ao selecionar arquivo(s)!\n${error.toString().replaceFirst('Exception: ', '')}',
                                  );
                                }).whenComplete(() {
                                  setState(() {});
                                });
                              },
                              icon: Icons.upload,
                              label: 'Carregar Capa',
                            ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.lgpdController.pdfInfo != null &&
                    widget.lgpdController.imageData != null)
                  CustomElevatedButtonIcon(
                    onPressed: () {
                      widget.post(context);
                    },
                    icon: Icons.save,
                    label: 'Salvar',
                  ),
                const SizedBox(height: 50),
                CustomElevatedButtonList(
                  buttonkey: buttonKeyPDF,
                  onPressed: widget.toggleShowListView,
                  listIsOpen: widget.showListView,
                  text: 'Visualizar Política e Segurança Lançadas essa Semana',
                ),
                const SizedBox(height: 12),
                if (widget.showListView)
                  ListViewWeek<LgpdModel>(
                    dataFuture: widget.dataFuture!,
                    itemConverter: (dynamic item) {
                      if (item is LgpdModel) {
                        return item;
                      }
                    },
                    updateItem: (item, descricao) => widget.lgpdController
                        .updateLgpd(lgpdId: item, description: descricao),
                    deleteItem: (item) =>
                        widget.lgpdController.deleteLgpd(lgpdId: item),
                    route: 'uploadLGPD',
                    titleOptionEdit: 'Edição da Política e Privacidade',
                  ),
              ],
            ),
          ),
        ),
        if (widget.isLoading) const CustomSavingScreenUpload(),
      ],
    );
  }
}
