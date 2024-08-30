import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:intraflow/models/user_images_model.dart';

class UserImagesController {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  User user = FirebaseAuth.instance.currentUser!;

  Future<String?> postUserImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      await _storage.ref("usuarios/${user.uid}/$fileName.png").putData(bytes);

      String url = await _storage
          .ref("usuarios/${user.uid}/$fileName.png")
          .getDownloadURL();

      await user.updatePhotoURL(url);

      if (kDebugMode) {
        print('postUserImage executado com sucesso: $url');
      }
      return url;
    } on FirebaseException catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.setCustomKey(
            'exceção_postUserImageFromBytes', e.toString());
        _crashlytics.recordError(e, stackTrace);
      }
      if (kDebugMode) {
        print('Erro ao executar postUserImage: $e');
      }
    }
    return null;
  }

  Future<String?> getUserImage({
    required String fileName,
  }) async {
    try {
      if (kDebugMode) {
        print('getUserImage executado');
      }
      return await _storage
          .ref("usuarios/${user.uid}/$fileName.png")
          .getDownloadURL();
    } on FirebaseException catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.setCustomKey('exceção_getUserImage', e.toString());
        _crashlytics.recordError(e, stackTrace);
      }
      if (kDebugMode) {
        print('Erro ao executar getUserImage');
      }
    }
    return null;
  }

  Future<List<UserImagesModel>> getListAllUserImages() async {
    try {
      ListResult result = await _storage.ref('usuarios/${user.uid}').listAll();
      List<Reference> listReferences = result.items;

      List<UserImagesModel> listFiles = [];

      for (Reference reference in listReferences) {
        String url = await reference.getDownloadURL();
        String name = reference.name;

        FullMetadata metadados = await reference.getMetadata();
        int? size = metadados.size;

        String sizeString = "Sem informação de tamanho.";

        if (size != null) {
          sizeString = "${size / 1000} Kb";
        }

        listFiles.add(UserImagesModel(
          url: url,
          name: name,
          size: sizeString,
          ref: reference,
        ));
      }

      if (kDebugMode) {
        print('getListAllUserImages executado');
      }

      return listFiles;
    } on FirebaseException catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.setCustomKey('exceção_getListAllUserImages', e.toString());
        _crashlytics.recordError(e, stackTrace);
      }
      if (kDebugMode) {
        print('Erro ao executar getListAllUserImages');
      }
    }
    if (kDebugMode) {
      print('getListAllUserImages executado');
    }
    return [];
  }

  Future<String?> updateUserImage({
    required String imagemUrl,
  }) async {
    try {
      await user.updatePhotoURL(imagemUrl);

      if (kDebugMode) {
        print('updateUserImage executado com sucesso');
      }
    } on FirebaseException catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.setCustomKey('updateUserImage', e.toString());
        _crashlytics.recordError(e, stackTrace);
      }
      if (kDebugMode) {
        print('Erro ao executar updateUserImage: $e');
      }
    }
    return null;
  }

  Future<String?> deleteUserImage({
    required UserImagesModel imageInfo,
  }) async {
    try {
      if (user.photoURL == imageInfo.url) {
        await user.updatePhotoURL('');
      }

      await imageInfo.ref.delete();
      if (kDebugMode) {
        print('deleteUserImage executado com sucesso');
      }
    } on FirebaseException catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.setCustomKey('exceção_deleteUserImage', e.toString());
        _crashlytics.recordError(e, stackTrace);
      }
      if (kDebugMode) {
        print('Erro ao executar deleteUserImage: $e');
      }
    }
    return null;
  }
}
