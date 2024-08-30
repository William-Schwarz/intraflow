import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intraflow/controllers/files_controller.dart';
import 'package:intraflow/controllers/lgpd_controller.dart';
import 'package:intraflow/models/lgpd_model.dart';
import 'package:intraflow/services/messaging/notification_types.dart';
import 'package:intraflow/views/pages/shipments/pages/lpgd/upload_images_lgpd_view.dart';
import 'package:intraflow/views/pages/shipments/pages/lpgd/upload_pdf_lgpd_view.dart';
import 'package:intraflow/widgets/custom_snack_bar.dart';
import 'package:intraflow/widgets/custom_tab_scaffold.dart';
import 'package:intraflow/widgets/custom_warning_messaging.dart';

class UploadLGPD extends StatefulWidget {
  const UploadLGPD({super.key});

  @override
  State<UploadLGPD> createState() => _UploadLGPDState();
}

class _UploadLGPDState extends State<UploadLGPD> with TickerProviderStateMixin {
  final LgpdController _lgpdController = LgpdController();
  final FilesController _filesController = FilesController();
  final TextEditingController _descricaoController = TextEditingController();
  final NotificationTypes _notificationTypes = NotificationTypes();
  late TabController _tabController;
  Future<List<LgpdModel>>? _lgpdDataFuture;
  List<LgpdModel> lgpdData = [];
  bool _showListView = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      vsync: this,
      length: 2,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _toggleListView() async {
    setState(() {
      _showListView = !_showListView;
      if (_showListView && _lgpdDataFuture == null) {
        _lgpdDataFuture = _loadLGPDData();
      }
    });
  }

  Future<List<LgpdModel>> _loadLGPDData() async {
    List<LgpdModel> data = await _lgpdController.getLgpd(option: 'semana');
    setState(() {
      lgpdData = data;
    });
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return CustomTabScaffold(
      title: 'Enviar Privacidade e Segurança',
      tabs: const [
        Tab(text: 'Imagens'),
        Tab(text: 'PDF'),
      ],
      controller: _tabController,
      tabViews: [
        UploadImagesLGPDView(
          filesController: _filesController,
          lgpdController: _lgpdController,
          descricaoController: _descricaoController,
          dataFuture: _lgpdDataFuture,
          post: _postLGPD,
          toggleShowListView: _toggleListView,
          showListView: _showListView,
          isLoading: _isLoading,
        ),
        UploadPDFLGPDView(
          filesController: _filesController,
          lgpdController: _lgpdController,
          descricaoController: _descricaoController,
          dataFuture: _lgpdDataFuture,
          post: _postLGPD,
          toggleShowListView: _toggleListView,
          showListView: _showListView,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  void _postLGPD(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    String descricao = _descricaoController.text;

    if (_tabController.index == 1) {
      List<Uint8List> imageDataList = [_lgpdController.imageData!];
      Uint8List? pdfFile = _lgpdController.pdfInfo?.bytes;

      await _lgpdController
          .postLgpd(
        description: descricao,
        imageDataList: imageDataList,
        pdfFile: pdfFile,
      )
          .then((String? error) {
        if (error == null) {
          ScaffoldMessenger.of(context).clearSnackBars();
          CustomSnackBar.showDefault(
              context, 'Privacidade e Segurança enviada com sucesso!');

          _notificationTypes.newLgpdNotification();

          setState(() {
            _descricaoController.clear();
            _lgpdController.pdfInfo = null;
            _lgpdController.imageData = null;
            _showListView = false;
            _lgpdDataFuture = null;
            _isLoading = false;
          });
        } else {
          CustomWarningMessaging.showWarningDialog(context, error);
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else {
      await _lgpdController
          .postLgpd(
        description: descricao,
        imageDataList: _filesController.imageDataList,
      )
          .then((String? error) {
        if (error == null) {
          ScaffoldMessenger.of(context).clearSnackBars();
          CustomSnackBar.showDefault(
              context, 'Privacidade e Segurança enviada com sucesso!');

          _notificationTypes.newLgpdNotification();

          setState(() {
            _descricaoController.clear();
            _filesController.imageDataList.clear();
            _showListView = false;
            _lgpdDataFuture = null;
            _isLoading = false;
          });
        } else {
          CustomWarningMessaging.showWarningDialog(context, error);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}
