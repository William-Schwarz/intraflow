import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intraflow/controllers/files_controller.dart';
import 'package:intraflow/controllers/menus_controller.dart';
import 'package:intraflow/models/menus_model.dart';
import 'package:intraflow/services/messaging/notification_types.dart';
import 'package:intraflow/utils/helpers/app_config.dart';
import 'package:intraflow/utils/helpers/formatting.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/views/lists/release_week/list_view_cardapios_released_week.dart';
import 'package:intraflow/widgets/custom_app_bar.dart';
import 'package:intraflow/widgets/custom_elevated_button_icon.dart';
import 'package:intraflow/widgets/custom_elevated_button_list.dart';
import 'package:intraflow/widgets/custom_error_messaging.dart';
import 'package:intraflow/widgets/custom_reorderable_list_view.dart';
import 'package:intraflow/widgets/custom_saving_screen_upload.dart';
import 'package:intraflow/widgets/custom_snack_bar.dart';
import 'package:intraflow/widgets/custom_text_field.dart';
import 'package:intraflow/widgets/custom_warning_messaging.dart';

class UploadMenus extends StatefulWidget {
  const UploadMenus({super.key});

  @override
  State<UploadMenus> createState() => _UploadMenusState();
}

class _UploadMenusState extends State<UploadMenus> {
  final GlobalKey _buttonKey = GlobalKey();
  final MenusController _menusController = MenusController();
  final FilesController _filesController = FilesController();
  final TextEditingController _descriptionController = TextEditingController();
  final NotificationTypes _notificationTypes = NotificationTypes();
  late DateTime _startDate;
  late DateTime _endDate;
  late String _description = '';
  Future<List<MenusModel>>? _menusDataFuture;
  List<MenusModel> menusData = [];
  bool isLoading = false;
  bool _showListView = false;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = _startDate.add(const Duration(days: 4));
  }

  Future<void> _toggleListView() async {
    setState(() {
      _showListView = !_showListView;
      if (_showListView && _menusDataFuture == null) {
        _menusDataFuture = _loadMenusData();
      }
    });
  }

  Future<List<MenusModel>> _loadMenusData() async {
    List<MenusModel> data = await _menusController.getMenus(option: 'semana');
    setState(() {
      menusData = data;
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
        title: 'Enviar Cardápio',
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
                          labelText: 'Descrição do Cardápio',
                          hintText:
                              'Aqui você deve descrever brevemente o cardápio.',
                          maxLength: 50,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Wrap(
                          spacing: 12,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                _selectStartDate(context: context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CustomColors.tertiaryColor,
                              ),
                              icon: const Icon(
                                Icons.calendar_today,
                                color: CustomColors.secondaryColor,
                              ),
                              label: Text(
                                'Início: ${Formatter.formatDate(_startDate)}',
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                _selectEndDate(context: context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CustomColors.tertiaryColor,
                              ),
                              icon: const Icon(
                                Icons.calendar_today,
                                color: CustomColors.secondaryColor,
                              ),
                              label: Text(
                                'Fim: ${Formatter.formatDate(_endDate)}',
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
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
                                    'Erro ao selecionar arquivo(s)!\n${error.toString().replaceFirst(
                                          'Exception: ',
                                          '',
                                        )}',
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
                              _postMenu(context: context);
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
                          text: 'Visualizar Cardápios Lançados essa Semana',
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        if (_showListView)
                          ListViewMenusWeek<MenusModel>(
                            dataFuture: _menusDataFuture!,
                            itemConverter: (dynamic item) {
                              if (item is MenusModel) {
                                return item;
                              }
                            },
                            updateItem: (item, descricao) =>
                                _menusController.updateMenu(
                                    menuID: item, description: descricao),
                            deleteItem: (item) =>
                                _menusController.deleteMenu(menuId: item),
                            route: 'uploadCardapio',
                            titleOptionEdit: 'Edição do cardápio',
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isLoading) const CustomSavingScreenUpload(),
            ],
          );
        },
      ),
    );
  }

  // Seleciona a data de início
  Future<void> _selectStartDate({
    required BuildContext context,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked.isBefore(_endDate) && mounted) {
      setState(() {
        _startDate = picked;
      });
    } else if (picked != null && mounted) {
      _warnings(
        endDate: true,
        startDate: false,
      );
    }
  }

  // Seleciona a data de término
  Future<void> _selectEndDate({
    required BuildContext context,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked.isAfter(_startDate) && mounted) {
      setState(() {
        _endDate = picked;
      });
    } else if (picked != null && mounted) {
      _warnings(
        startDate: false,
        endDate: true,
      );
    }
  }

  // Exibe mensagens de aviso ou erro
  void _warnings({
    required bool startDate,
    required bool endDate,
  }) {
    if (startDate) {
      CustomWarningMessaging.showWarningDialog(
        context,
        'Por favor, selecione uma data inicial válida antes da data final.',
      );
    } else if (endDate) {
      CustomWarningMessaging.showWarningDialog(
        context,
        'Por favor, selecione uma data inicial válida após a data inicial.',
      );
    } else {
      CustomErrorMessaging.showErrorDialog(
        context,
        'Erro desconhecido.',
      );
    }
  }

  // Método para enviar o cardápio
  Future<void> _postMenu({
    required BuildContext context,
  }) async {
    setState(() {
      isLoading = true;
    });

    await _menusController
        .postMenu(
            description: _description,
            dataInicial:
                DateTime(_startDate.year, _startDate.month, _startDate.day),
            dataFinal: DateTime(_endDate.year, _endDate.month, _endDate.day),
            imageDataList: _filesController.imageDataList)
        .then((String? error) {
      if (error == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        CustomSnackBar.showDefault(
          context,
          'Cardápio enviado com sucesso!',
        );

        _notificationTypes.newMenuNotification();

        setState(() {
          _descriptionController.clear();
          _filesController.imageDataList.clear();
          _startDate = DateTime.now();
          _endDate = _startDate.add(const Duration(days: 4));
          _showListView = false;
          _menusDataFuture = _loadMenusData();
          isLoading = !isLoading;
        });
      } else {
        CustomWarningMessaging.showWarningDialog(
          context,
          error,
        );
        setState(() {
          isLoading = false;
        });
      }
    });
  }
}
