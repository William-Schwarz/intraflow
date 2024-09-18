import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intraflow/controllers/code_ethics_controller.dart';
import 'package:intraflow/controllers/files_controller.dart';
import 'package:intraflow/models/code_ethics_model.dart';
import 'package:intraflow/services/messaging/notification_types.dart';
import 'package:intraflow/utils/helpers/app_config.dart';
import 'package:intraflow/views/lists/release_week/list_view_images_released_week.dart';
import 'package:intraflow/widgets/custom_app_bar.dart';
import 'package:intraflow/widgets/custom_elevated_button_icon.dart';
import 'package:intraflow/widgets/custom_elevated_button_list.dart';
import 'package:intraflow/widgets/custom_reorderable_list_view.dart';
import 'package:intraflow/widgets/custom_saving_screen_upload.dart';
import 'package:intraflow/widgets/custom_snack_bar.dart';
import 'package:intraflow/widgets/custom_text_field.dart';
import 'package:intraflow/widgets/custom_warning_messaging.dart';

class UploadCodeEthics extends StatefulWidget {
  const UploadCodeEthics({super.key});

  @override
  State<UploadCodeEthics> createState() => _UploadCodeEthicsState();
}

class _UploadCodeEthicsState extends State<UploadCodeEthics> {
  final GlobalKey _buttonKey = GlobalKey();
  final CodeEthicsController _codeEthicsController = CodeEthicsController();
  final FilesController _filesController = FilesController();
  final TextEditingController _descriptionController = TextEditingController();
  final NotificationTypes _notificationTypes = NotificationTypes();
  late String _description = '';
  Future<List<CodeEthicsModel>>? _codeEthicsDataFuture;
  List<CodeEthicsModel> codeEthicsData = [];
  bool _showListView = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _toggleListView() async {
    setState(() {
      _showListView = !_showListView;
      if (_showListView && _codeEthicsDataFuture == null) {
        _codeEthicsDataFuture = _loadCodeEthicsData();
      }
    });
  }

  Future<List<CodeEthicsModel>> _loadCodeEthicsData() async {
    List<CodeEthicsModel> data =
        await _codeEthicsController.getCodeEthics(option: 'semana');
    setState(() {
      codeEthicsData = data;
    });
    return data;
  }

  void _updateImageDataList(List<Uint8List> updatedList) {
    setState(() {
      _filesController.imageDataList = updatedList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Enviar Código de Ética',
        leadingVisible: true,
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Stack(
            alignment: Alignment.center,
            children: [
              SingleChildScrollView(
                child: Center(
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
                          controller: _descriptionController,
                          onChanged: (value) {
                            setState(() {
                              _description = value;
                            });
                          },
                          labelText: 'Descrição do Código de Ética',
                          hintText:
                              'Aqui você deve descrever brevemente o código de ética.',
                          maxLength: 50,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        if (_filesController.imageDataList.isNotEmpty)
                          CustomReorderableListView(
                            filesController: _filesController,
                            onRemoveItem: _updateImageDataList,
                          ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomElevatedButtonIcon(
                              onPressed: () async {
                                await _filesController
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
                            const SizedBox(
                              width: 16,
                            ),
                            if (_filesController.imageDataList.isNotEmpty)
                              CustomElevatedButtonIcon(
                                onPressed: () {
                                  setState(() {
                                    _filesController.imageDataList.clear();
                                  });
                                },
                                icon: Icons.delete,
                                label: 'Remover Tudo',
                              ),
                          ],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        if (_filesController.imageDataList.isNotEmpty)
                          CustomElevatedButtonIcon(
                            onPressed: () {
                              _postCodeEthics(context: context);
                            },
                            icon: Icons.save,
                            label: 'Salvar',
                          ),
                        const SizedBox(
                          height: 16,
                        ),
                        CustomElevatedButtonList(
                          buttonkey: _buttonKey,
                          onPressed: _toggleListView,
                          listIsOpen: _showListView,
                          text:
                              'Visualizar Código de Ética Lançados essa Semana',
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        if (_showListView)
                          ListViewImageWeek<CodeEthicsModel>(
                            dataFuture: _codeEthicsDataFuture!,
                            itemConverter: (dynamic item) {
                              if (item is CodeEthicsModel) {
                                return item;
                              }
                            },
                            updateItem: (item, descricao) =>
                                _codeEthicsController.updateCodeEthics(
                                    codeEthicsId: item, description: descricao),
                            deleteItem: (item) => _codeEthicsController
                                .deleteCodeEthics(codeEthicsId: item),
                            route: 'uploadCodigoEtica',
                            titleOptionEdit: 'Edição do Código de Ética',
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isLoading) const CustomSavingScreenUpload(),
            ],
          );
        },
      ),
    );
  }

  Future<void> _postCodeEthics({
    required BuildContext context,
  }) async {
    setState(() {
      _isLoading = true;
    });

    await _codeEthicsController
        .postCodeEthics(
            description: _description,
            imageDataList: _filesController.imageDataList)
        .then((String? error) {
      if (error == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        CustomSnackBar.showDefault(
          context,
          'Código de Ética enviado com sucesso!',
        );

        _notificationTypes.newCodeEthicsNotification();

        setState(() {
          _descriptionController.clear();
          _filesController.imageDataList.clear();
          _showListView = false;
          _codeEthicsDataFuture = _loadCodeEthicsData();
          _isLoading = !_isLoading;
        });
      } else {
        CustomWarningMessaging.showWarningDialog(
          context,
          error,
        );
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
}
