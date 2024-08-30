import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intraflow/controllers/files_controller.dart';
import 'package:intraflow/controllers/user_images_controller.dart';
import 'package:intraflow/models/user_images_model.dart';
import 'package:intraflow/services/local/local_user_controller.dart';
import 'package:intraflow/utils/helpers/app_config.dart';
import 'package:intraflow/utils/helpers/formatting.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/widgets/custom_box_decoration_list.dart';
import 'package:intraflow/widgets/custom_divider.dart';
import 'package:intraflow/widgets/custom_snack_bar.dart';
import 'package:provider/provider.dart';

class UserImagesView extends StatefulWidget {
  const UserImagesView({super.key});

  @override
  State<UserImagesView> createState() => _UserImagesViewState();
}

class _UserImagesViewState extends State<UserImagesView> {
  final UserImagesController _usersImagesController = UserImagesController();
  final FilesController _filesController = FilesController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  final int _maxImages = 2;
  bool _isLoading = false;
  bool _isSelectingImage = false;
  List<UserImagesModel> _listFiles = [];
  int _uploadedImages = 0;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _toggleLoading() {
    if (mounted) {
      setState(() {
        _isLoading = !_isLoading;
      });
    }
  }

  void _toggleSelectingImage() {
    if (mounted) {
      setState(() {
        _isSelectingImage = !_isSelectingImage;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localUserController = Provider.of<LocalUserController>(context);
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            gradient: CustomColors.primaryGradient,
          ),
          child: Center(
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                'Edição do Perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _uploadImage,
            icon: const Icon(Icons.upload),
          ),
          IconButton(
            onPressed: _isLoading ? null : _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.height *
                  AppConfig().widhtMediaQueryWebPage!,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  (_isSelectingImage)
                      ? const CircularProgressIndicator() // Mostrar o indicador de progresso circular
                      : (_auth.currentUser?.photoURL != null &&
                              _auth.currentUser!.photoURL!.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(64),
                              child: Image.network(
                                localUserController.photoUrl!,
                                width: 128,
                                height: 128,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const CircleAvatar(
                                  backgroundColor: CustomColors.tertiaryColor,
                                  radius: 64,
                                  child: Icon(
                                    Icons.person,
                                    size: 32,
                                  ),
                                ),
                              ),
                            )
                          : const CircleAvatar(
                              backgroundColor: CustomColors.tertiaryColor,
                              radius: 64,
                              child: Icon(
                                Icons.person,
                                size: 32,
                              ),
                            ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CustomDivider(),
                  ),
                  const Text(
                    "Histórico de Imagens",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: (_isLoading)
                            ? Container(
                                height: 88,
                                decoration: CustomBoxDecorationList
                                    .defaultBoxDecoration(),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Container(
                                decoration: CustomBoxDecorationList
                                    .defaultBoxDecoration(),
                                child: Column(
                                  children: List.generate(
                                    _listFiles.length,
                                    (index) {
                                      UserImagesModel imageInfo =
                                          _listFiles[index];
                                      return ListTile(
                                        onTap: () {
                                          _selectImage(imageInfo: imageInfo);
                                        },
                                        leading: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          child: Image.network(
                                            imageInfo.url,
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                        title: Text(
                                          Formatter.formatDateTime(
                                              imageInfo.name),
                                        ),
                                        subtitle: Text(imageInfo.size),
                                        trailing: IconButton(
                                          onPressed: () {
                                            _deleteImage(
                                              imageInfo: imageInfo,
                                              index: index,
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadImage() async {
    if (_uploadedImages >= _maxImages) {
      ScaffoldMessenger.of(context).clearSnackBars();
      CustomSnackBar.showDefault(
        context,
        'Você só pode carregar até $_maxImages imagens.\n Para carregar outra, exclua alguma já existente.',
      );

      return;
    }

    _toggleLoading();
    _toggleSelectingImage();

    Uint8List? imageBytes = await _filesController.pickImage();

    if (imageBytes != null) {
      _usersImagesController
          .postUserImage(
        bytes: imageBytes,
        fileName: DateTime.now().toString(),
      )
          .then((String? urlDownload) {
        if (urlDownload != null) {
          // Atualize a URL da foto no Provider
          Provider.of<LocalUserController>(context, listen: false)
              .updateLocalUserPhotoUrl(newPhotoUrl: urlDownload);

          _reload();

          ScaffoldMessenger.of(context).clearSnackBars();
          CustomSnackBar.showDefault(
            context,
            'Imagem de perfil atualizada com sucesso!',
          );
        }
      }).catchError((error) {
        CustomSnackBar.showDefault(
          context,
          error,
        );
      }).whenComplete(() {
        _toggleLoading();
        _toggleSelectingImage();
      });
    }
  }

  Future<void> _selectImage({
    required UserImagesModel imageInfo,
  }) async {
    if (_auth.currentUser!.photoURL == imageInfo.url) {
      ScaffoldMessenger.of(context).clearSnackBars();
      CustomSnackBar.showDefault(
        context,
        'A imagem selecionada já está como a de perfil.',
      );
      return;
    }

    _toggleSelectingImage();

    await _usersImagesController
        .updateUserImage(imagemUrl: imageInfo.url)
        .then((_) {
      // Atualize a URL da foto no Provider
      Provider.of<LocalUserController>(context, listen: false)
          .updateLocalUserPhotoUrl(newPhotoUrl: imageInfo.url);

      ScaffoldMessenger.of(context).clearSnackBars();
      CustomSnackBar.showDefault(
        context,
        'Imagem de perfil atualizada com sucesso!',
      );
    }).catchError((error) {
      CustomSnackBar.showDefault(
        context,
        error,
      );
    }).whenComplete(() {
      _toggleSelectingImage();
    });
  }

  Future<void> _deleteImage({
    required UserImagesModel imageInfo,
    required int index,
  }) async {
    _toggleLoading();

    await _usersImagesController
        .deleteUserImage(
      imageInfo: imageInfo,
    )
        .then((_) {
      if (_auth.currentUser?.photoURL == imageInfo.url) {
        _toggleSelectingImage();
        Provider.of<LocalUserController>(context, listen: false)
            .updateLocalUserPhotoUrl(newPhotoUrl: '')
            .whenComplete(
              () => _toggleSelectingImage(),
            );
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      CustomSnackBar.showDefault(
        context,
        'Imagem excluída com sucesso!',
      );

      setState(() {
        _listFiles.removeAt(index);
        _uploadedImages = _listFiles.length;
      });
    }).catchError((error) {
      CustomSnackBar.showDefault(
        context,
        error,
      );
    }).whenComplete(() {
      _toggleLoading();
    });
  }

  Future<void> _reload() async {
    _toggleLoading();

    await _usersImagesController.getListAllUserImages().then((images) {
      setState(() {
        _listFiles = images;
        _uploadedImages = images.length;
      });
    }).catchError((error) {
      CustomSnackBar.showDefault(
        context,
        error,
      );
    }).whenComplete(() {
      _toggleLoading();
    });
  }
}
