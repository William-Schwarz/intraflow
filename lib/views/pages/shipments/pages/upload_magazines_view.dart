import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:intraflow/controllers/magazines_controller.dart';
import 'package:intraflow/models/magazines_model.dart';
import 'package:intraflow/services/messaging/notification_types.dart';
import 'package:intraflow/utils/helpers/app_config.dart';
import 'package:intraflow/views/lists/release_week/list_view_pdf_released_week.dart';
import 'package:intraflow/views/pdf_screen_view.dart';
import 'package:intraflow/widgets/custom_app_bar.dart';
import 'package:intraflow/widgets/custom_elevated_button_icon.dart';
import 'package:intraflow/widgets/custom_elevated_button_list.dart';
import 'package:intraflow/widgets/custom_gestor_detector_list.dart';
import 'package:intraflow/widgets/custom_saving_screen_upload.dart';
import 'package:intraflow/widgets/custom_snack_bar.dart';
import 'package:intraflow/widgets/custom_text_field.dart';
import 'package:intraflow/widgets/custom_warning_messaging.dart';

class UploadMagazinesView extends StatefulWidget {
  const UploadMagazinesView({super.key});

  @override
  State<UploadMagazinesView> createState() => _UploadMagazinesViewState();
}

class _UploadMagazinesViewState extends State<UploadMagazinesView> {
  final GlobalKey _buttonKey = GlobalKey();
  final MagazinesController _magazinesController = MagazinesController();
  final TextEditingController _descriptionController = TextEditingController();
  final NotificationTypes _notificationTypes = NotificationTypes();
  late String _description = '';
  Future<List<MagazinesModel>>? _magazinesDataFuture;
  List<MagazinesModel> magazinesData = [];
  bool _showListView = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _toggleListView() async {
    setState(() {
      _showListView = !_showListView;
      if (_showListView && _magazinesDataFuture == null) {
        _magazinesDataFuture = _loadMagazinesData();
      }
    });
  }

  Future<List<MagazinesModel>> _loadMagazinesData() async {
    List<MagazinesModel> data =
        await _magazinesController.getMagazines(option: 'semana');
    setState(() {
      magazinesData = data;
    });
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Enviar Revista',
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
                          labelText: 'Descrição da Revista',
                          hintText:
                              'Aqui você deve descrever brevemente a revista',
                          maxLength: 50,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        if (_magazinesController.pdfInfo != null)
                          Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                                leading: _magazinesController.imageData != null
                                    ? CustomGestureDetectorList(
                                        imageData:
                                            _magazinesController.imageData,
                                        child: Image.memory(
                                          _magazinesController.imageData!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : null,
                                title: Text(
                                  'Arquivo: ${_magazinesController.pdfInfo!.name}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Tamanho: ${(_magazinesController.pdfInfo!.size / 1024).toStringAsFixed(2)} KB',
                                ),
                                trailing: Visibility(
                                  visible: (!kIsWeb),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.search,
                                      size: 32,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PDFScreenView(
                                            title: _magazinesController
                                                .pdfInfo!.name,
                                            file: _magazinesController
                                                .pdfInfo!.file!,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )),
                          ),
                        const SizedBox(
                          height: 8,
                        ),
                        Wrap(
                          children: [
                            (_magazinesController.pdfInfo != null)
                                ? CustomElevatedButtonIcon(
                                    onPressed: () {
                                      setState(() {
                                        _magazinesController.pdfInfo = null;
                                      });
                                    },
                                    icon: Icons.picture_as_pdf,
                                    label: 'Remover',
                                  )
                                : CustomElevatedButtonIcon(
                                    onPressed: () async {
                                      await _magazinesController
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
                            const SizedBox(
                              width: 8,
                            ),
                            Visibility(
                              visible: _magazinesController.pdfInfo != null,
                              child: (_magazinesController.imageData != null)
                                  ? CustomElevatedButtonIcon(
                                      onPressed: () {
                                        setState(() {
                                          _magazinesController.imageData = null;
                                        });
                                      },
                                      icon: Icons.image,
                                      label: 'Remover',
                                    )
                                  : CustomElevatedButtonIcon(
                                      onPressed: () async {
                                        await _magazinesController
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
                        const SizedBox(
                          height: 16,
                        ),
                        if (_magazinesController.pdfInfo != null &&
                            _magazinesController.imageData != null)
                          CustomElevatedButtonIcon(
                            onPressed: () {
                              _postMagazine(context: context);
                            },
                            icon: Icons.save,
                            label: 'Salvar',
                          ),
                        const SizedBox(
                          height: 50,
                        ),
                        CustomElevatedButtonList(
                          buttonkey: _buttonKey,
                          onPressed: _toggleListView,
                          listIsOpen: _showListView,
                          text: 'Visualizar Revistas Lançadas essa Semana',
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        if (_showListView)
                          ListViewPdfWeek<MagazinesModel>(
                            dataFuture: _magazinesDataFuture!,
                            itemConverter: (dynamic item) {
                              if (item is MagazinesModel) {
                                return item;
                              }
                            },
                            updateItem: (item, descricao) =>
                                _magazinesController.updateRevista(
                                    item, descricao),
                            deleteItem: (item) => _magazinesController
                                .deleteMagazine(magazineId: item),
                            route: 'uploadRevista',
                            titleOptionEdit: 'Edição da revista',
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

  Future<void> _postMagazine({
    required BuildContext context,
  }) async {
    setState(() {
      _isLoading = true;
    });

    Uint8List? pdfFile = _magazinesController.pdfInfo?.bytes;
    if (pdfFile != null) {
      await _magazinesController
          .postMagazine(
        description: _description,
        imageData: _magazinesController.imageData!,
        pdfFile: pdfFile,
      )
          .then((String error) {
        if (error.startsWith('http')) {
          setState(() {
            _descriptionController.clear();
            _magazinesController.pdfInfo = null;
            _magazinesController.imageData = null;
            _showListView = false;
            _magazinesDataFuture = _loadMagazinesData();
            _isLoading = !_isLoading;
          });

          ScaffoldMessenger.of(context).clearSnackBars();
          CustomSnackBar.showDefault(
            context,
            'Revista enviada com sucesso!',
          );

          _notificationTypes.newMagazineNotification();
        } else {
          CustomWarningMessaging.showWarningDialog(
            context,
            error,
          );
        }
      });
    } else {
      CustomWarningMessaging.showWarningDialog(
        context,
        'Selecione um arquivo PDF.',
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
}
