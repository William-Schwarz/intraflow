import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intraflow/controllers/announcements_controller.dart';
import 'package:intraflow/controllers/files_controller.dart';
import 'package:intraflow/models/announcements_model.dart';
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

class UploadAnnouncements extends StatefulWidget {
  const UploadAnnouncements({super.key});

  @override
  State<UploadAnnouncements> createState() => _UploadAnnouncementsState();
}

class _UploadAnnouncementsState extends State<UploadAnnouncements> {
  final GlobalKey _buttonKey = GlobalKey();
  final AnnouncementsController _announcementsController =
      AnnouncementsController();
  final FilesController _filesController = FilesController();
  final TextEditingController _descriptionController = TextEditingController();
  final NotificationTypes _notificationTypes = NotificationTypes();
  late String _description = '';
  Future<List<AnnouncementsModel>>? _announcementsDataFuture;
  List<AnnouncementsModel> announcementsData = [];
  bool _showListView = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _toggleListView() async {
    setState(() {
      _showListView = !_showListView;
      if (_showListView && _announcementsDataFuture == null) {
        _announcementsDataFuture = _loadAnnouncementsData();
      }
    });
  }

  Future<List<AnnouncementsModel>> _loadAnnouncementsData() async {
    List<AnnouncementsModel> data =
        await _announcementsController.getAnnouncements(option: 'semana');
    setState(() {
      announcementsData = data;
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
        title: 'Enviar Comunicado',
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
                          labelText: 'Descrição do Comunicado',
                          hintText:
                              'Aqui você deve descrever brevemente o comunicado.',
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
                              _postAnnouncements(context: context);
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
                          text: 'Visualizar Comunicados Lançados essa Semana',
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        if (_showListView)
                          ListViewImageWeek<AnnouncementsModel>(
                            dataFuture: _announcementsDataFuture!,
                            itemConverter: (dynamic item) {
                              if (item is AnnouncementsModel) {
                                return item;
                              }
                            },
                            updateItem: (item, descricao) =>
                                _announcementsController.updateAnnouncement(
                                    announcementId: item,
                                    description: descricao),
                            deleteItem: (item) => _announcementsController
                                .deleteAnnouncement(announcementId: item),
                            route: 'uploadComunicado',
                            titleOptionEdit: 'Edição do comunicado',
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

  Future<void> _postAnnouncements({
    required BuildContext context,
  }) async {
    setState(() {
      _isLoading = true;
    });

    await _announcementsController
        .postAnnouncement(
            description: _description,
            imageDataList: _filesController.imageDataList)
        .then((String? error) {
      if (error == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        CustomSnackBar.showDefault(
          context,
          'Comunicado enviado com sucesso!',
        );

        _notificationTypes.newAnnouncementsNotification();

        setState(() {
          _descriptionController.clear();
          _filesController.imageDataList.clear();
          _showListView = false;
          _announcementsDataFuture = _loadAnnouncementsData();
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
