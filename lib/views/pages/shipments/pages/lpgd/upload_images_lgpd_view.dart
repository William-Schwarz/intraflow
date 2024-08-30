import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intraflow/controllers/files_controller.dart';
import 'package:intraflow/controllers/lgpd_controller.dart';
import 'package:intraflow/models/lgpd_model.dart';
import 'package:intraflow/utils/helpers/app_config.dart';
import 'package:intraflow/views/lists/release_week/list_view_released_week.dart';
import 'package:intraflow/widgets/custom_elevated_button_icon.dart';
import 'package:intraflow/widgets/custom_elevated_button_list.dart';
import 'package:intraflow/widgets/custom_reorderable_list_view.dart';
import 'package:intraflow/widgets/custom_saving_screen_upload.dart';
import 'package:intraflow/widgets/custom_snack_bar.dart';
import 'package:intraflow/widgets/custom_text_field.dart';

class UploadImagesLGPDView extends StatefulWidget {
  final LgpdController lgpdController;
  final FilesController filesController;
  final TextEditingController descricaoController;
  final void Function(BuildContext) post;
  final Future<void> Function() toggleShowListView;
  final bool showListView;
  final bool isLoading;
  final Future<List<LgpdModel>>? dataFuture;
  const UploadImagesLGPDView({
    Key? key,
    required this.lgpdController,
    required this.filesController,
    required this.descricaoController,
    required this.post,
    required this.toggleShowListView,
    required this.showListView,
    required this.isLoading,
    this.dataFuture,
  }) : super(key: key);

  @override
  State<UploadImagesLGPDView> createState() => _UploadImagesLGPDViewState();
}

class _UploadImagesLGPDViewState extends State<UploadImagesLGPDView> {
  GlobalKey buttonKeyImage = GlobalKey();

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
                  hintText: 'Ex: Como Ativar Ligações Wi-fi',
                  maxLength: 50,
                ),
                const SizedBox(height: 16),
                if (widget.filesController.imageDataList.isNotEmpty)
                  CustomReorderableListView(
                    imageDataList: widget.filesController.imageDataList,
                    onRemoveItem: _updateImageDataList,
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomElevatedButtonIcon(
                      onPressed: () async {
                        await widget.filesController
                            .pickImages()
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
                      label: 'Selecionar Imagens',
                    ),
                    const SizedBox(width: 16),
                    if (widget.filesController.imageDataList.isNotEmpty)
                      CustomElevatedButtonIcon(
                        onPressed: () {
                          setState(() {
                            widget.filesController.imageDataList.clear();
                          });
                        },
                        icon: Icons.delete,
                        label: 'Remover Tudo',
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.filesController.imageDataList.isNotEmpty)
                  CustomElevatedButtonIcon(
                    onPressed: () {
                      widget.post(context);
                    },
                    icon: Icons.save,
                    label: 'Salvar',
                  ),
                const SizedBox(height: 16),
                CustomElevatedButtonList(
                  buttonkey: buttonKeyImage,
                  onPressed: widget.toggleShowListView,
                  listIsOpen: widget.showListView,
                  text:
                      'Visualizar Privacidades e Seguranças Lançadas essa Semana',
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
                    titleOptionEdit: 'Edição da Privacidade e Segurança',
                  ),
              ],
            ),
          ),
        ),
        if (widget.isLoading) const CustomSavingScreenUpload(),
      ],
    );
  }

  void _updateImageDataList(List<Uint8List> updatedList) {
    setState(() {
      widget.filesController.imageDataList = updatedList;
    });
  }
}
