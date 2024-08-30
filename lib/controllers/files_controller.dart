import 'dart:async';
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intraflow/models/info_files.dart';
import 'package:path_provider/path_provider.dart';

class FilesController extends ChangeNotifier {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  Future<Uint8List?> pickImage() async {
    if (kIsWeb) {
      // Código original para a Web
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
      );

      if (result != null) {
        final fileName = result.files.single.name;
        final extension = fileName.split('.').last.toLowerCase();

        if (!['png', 'jpg', 'jpeg'].contains(extension)) {
          throw Exception('Tipo de arquivo não suportado: $fileName');
        }

        final bytes = result.files.single.bytes;
        if (bytes != null) {
          return bytes;
        }
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        return await imageFile.readAsBytes();
      }
    }

    return null;
  }

  List<Uint8List> imageDataList = [];
  Future<void> pickImages() async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
        allowMultiple: true,
      );

      if (result != null) {
        if (result.files.length > 8) {
          throw Exception('Você pode selecionar no máximo 8 imagens.');
        }

        for (var file in result.files) {
          final fileName = file.name;
          final extension = fileName.split('.').last.toLowerCase();

          if (!['png', 'jpg', 'jpeg'].contains(extension)) {
            throw Exception('Tipo de arquivo não suportado: $fileName');
          }

          if (file.bytes != null) {
            Uint8List bytes = Uint8List.fromList(file.bytes!);
            imageDataList.add(bytes);
          }
        }
      }
    } else {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(
        limit: 8,
      );

      if (pickedFiles.length > 8) {
        throw Exception('Você pode selecionar no máximo 8 imagens.');
      }

      for (var pickedFile in pickedFiles) {
        File imageFile = File(pickedFile.path);
        Uint8List bytes = await imageFile.readAsBytes();
        imageDataList.add(bytes);
      }
    }

    notifyListeners();
  }

  Future<Uint8List> resizeImage({
    required Uint8List imageData,
    required int width,
    required int height,
  }) async {
    Image image = decodeImage(imageData)!;
    Image resizedImage = copyResize(image, width: width, height: height);
    return Uint8List.fromList(encodePng(resizedImage));
  }

  Future<InfoFilesModel?> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      String name = file.name;
      int size = file.size;
      String extension = file.extension!.toLowerCase();

      // Verificação de extensão
      if (extension != 'pdf') {
        throw Exception('Tipo de arquivo não suportado: $name');
      }

      Uint8List? bytes;
      File? fileObject;

      if (kIsWeb) {
        bytes = result.files.single.bytes;
      } else {
        final path = file.path;
        if (path != null) {
          fileObject = File(path);
          bytes = fileObject.readAsBytesSync();
        }
      }

      if (bytes != null) {
        return InfoFilesModel(
          name: name,
          size: size,
          extension: extension,
          bytes: bytes,
          file: fileObject,
        );
      }
    }

    return null;
  }

  Future<File?> downloadAndSaveFile({
    required String url,
    required String firebaseDocId,
  }) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final documentDirectory = await getApplicationDocumentsDirectory();
        final fileName = '$firebaseDocId.pdf';
        final file = File('${documentDirectory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception('Erro ao fazer o download do PDF');
      }
    } catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.setCustomKey('exceção_downloadAndSaveFile', e.toString());
        _crashlytics.recordError(e, stackTrace);
      }
      throw Exception(e.toString());
    }
  }

  Future<File?> getFile({
    required String url,
    required String firebaseDocId,
  }) async {
    final localFile = await _getLocalFile(firebaseDocId: firebaseDocId);
    if (localFile != null) {
      if (kDebugMode) {
        print('Arquio buscado localmente: $localFile');
      }
      return localFile;
    } else {
      if (kDebugMode) {
        print('Arquio buscado no Firebase: $firebaseDocId');
      }
      return await downloadAndSaveFile(url: url, firebaseDocId: firebaseDocId);
    }
  }

  Future<File?> _getLocalFile({
    required String firebaseDocId,
  }) async {
    try {
      final documentDirectory = await getApplicationDocumentsDirectory();
      final fileName = '$firebaseDocId.pdf';
      final localFilePath = '${documentDirectory.path}/$fileName';
      final localFile = File(localFilePath);
      if (await localFile.exists()) {
        return localFile;
      } else {
        return null;
      }
    } catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.setCustomKey('exceção_getArquivosLocais', e.toString());
        _crashlytics.recordError(e, stackTrace);
      }
      throw Exception('Erro ao acessar os arquivos locais: $e');
    }
  }
}
