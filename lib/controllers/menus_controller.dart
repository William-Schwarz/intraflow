import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:intraflow/controllers/files_controller.dart';
import 'package:intraflow/models/menus_model.dart';
import 'package:intraflow/services/firebase/firebase_controller.dart';

class MenusController extends ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FilesController _filesController = FilesController();
  final FirebaseController _firebaseController = FirebaseController();

  Future<String?> getMenu({
    required String menuId,
  }) async {
    try {
      await _firestore.collection('Cardapios').doc(menuId).get();
      if (kDebugMode) {
        print('getMenu executado. Id: $menuId');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar getMenu: ${e.code}');
      }
      return e.code;
    }
    return null;
  }

  Future<List<MenusModel>> getMenus({
    required String option,
  }) async {
    List<MenusModel> menus = [];
    DateTime now = DateTime.now();

    DateTime startWeek = now.subtract(Duration(days: now.weekday));
    DateTime endWeek = startWeek
        .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    DateTime currentDate = now;
    DateTime dateStart =
        DateTime(currentDate.year, currentDate.month, currentDate.day)
            .add(const Duration(days: 1));
    DateTime dateEnd =
        DateTime(currentDate.year, currentDate.month, currentDate.day);
    try {
      QuerySnapshot allMenusSnapshot = await _firestore
          .collection('Cardapios')
          .orderBy('Data', descending: true)
          .get();
      QuerySnapshot querySnapshotDateStart = await _firestore
          .collection('Cardapios')
          .where('DataInicial', isLessThanOrEqualTo: dateStart)
          .orderBy('DataInicial', descending: true)
          .get();

      QuerySnapshot querySnapshotDateEnd = await _firestore
          .collection('Cardapios')
          .where('DataFinal', isGreaterThanOrEqualTo: dateEnd)
          .orderBy('DataFinal', descending: true)
          .get();

      Set<String> idsWithValidStartDate =
          querySnapshotDateStart.docs.map((doc) => doc.id).toSet();
      Set<String> isWithValidEndDate =
          querySnapshotDateEnd.docs.map((doc) => doc.id).toSet();

      Set<String> idsCurrentMenus =
          idsWithValidStartDate.intersection(isWithValidEndDate);

      Future<Map<String, List<String>>> getImageUrls({
        required String docId,
      }) async {
        // Define as referências para as imagens no Storage
        String refOriginal = 'cardapios/$docId/imagens/';
        String refThumb = 'cardapios/$docId/thumbnails/';

        ListResult originalImages = await _storage.ref(refOriginal).listAll();
        ListResult thumbImages = await _storage.ref(refThumb).listAll();

        List<String> originalImageUrls = [];
        List<String> thumbImageUrls = [];

        for (var item in originalImages.items) {
          originalImageUrls.add(await item.getDownloadURL());
        }
        for (var item in thumbImages.items) {
          thumbImageUrls.add(await item.getDownloadURL());
        }

        return {
          'ImagemURLs': originalImageUrls,
          'ThumbURLs': thumbImageUrls,
        };
      }

      for (DocumentSnapshot doc in allMenusSnapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          DateTime menuDate = (data['Data'] as Timestamp).toDate();

          if ((option == 'atuais' && idsCurrentMenus.contains(doc.id)) ||
              (option == 'anteriores' &&
                  !idsCurrentMenus.contains(doc.id) &&
                  (data['DataInicial'] as Timestamp).toDate().isBefore(now)) ||
              (option == 'semana' &&
                  menuDate.isAfter(startWeek) &&
                  menuDate.isBefore(endWeek))) {
            Map<String, List<String>> imageUrls =
                await getImageUrls(docId: doc.id);

            menus.add(
              MenusModel(
                id: doc.id,
                descricao: data['Descricao'],
                dataInicial: (data['DataInicial'] as Timestamp).toDate(),
                dataFinal: (data['DataFinal'] as Timestamp).toDate(),
                imagemURL: imageUrls['ImagemURLs'] ?? [],
                thumbURL: imageUrls['ThumbURLs'] ?? [],
                data: menuDate,
              ),
            );
          }
        }
      }

      if (kDebugMode) {
        print('getMenus($option) executado');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar getMenus($option): ${e.code}');
      }
    }

    return menus;
  }

  Future<String?> postMenu({
    required String description,
    required DateTime dataInicial,
    required DateTime dataFinal,
    required List<Uint8List> imageDataList,
  }) async {
    try {
      final validationDescription =
          _firebaseController.validateDescription(description);
      if (validationDescription != null) {
        return '$validationDescription Descrição do Cardápio';
      }

      // Adiciona um novo documento ao Firestore para obter o ID do documento
      DocumentReference docRef = await _firestore.collection('Cardapios').add({
        'Descricao': description,
        'DataInicial': dataInicial,
        'DataFinal': dataFinal,
        'Data': DateTime.now(),
      });

      // Obtém o ID do documento
      String docId = docRef.id;

      for (int i = 0; i < imageDataList.length; i++) {
        Uint8List imageData = imageDataList[i];

        // Redimensiona a imagem
        Uint8List resizedImage = await _filesController.resizeImage(
            imageData: imageData, width: 200, height: 250);

        // Define as referências para as imagens no Storage
        String refOriginal =
            'cardapios/$docId/imagens/img-$i-${DateTime.now().toString()}.png';
        String refThumb =
            'cardapios/$docId/thumbnails/thumb-$i-${DateTime.now().toString()}.png';

        // Salva a imagem original no Firebase Storage
        await _storage.ref(refOriginal).putData(imageData);

        // Salva a imagem redimensionada no Firebase Storage
        await _storage.ref(refThumb).putData(resizedImage);

        if (kDebugMode) {
          print('postMenu executado para imagem $i');
        }
      }

      return null;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar postMenu: ${e.code}');
      }
      return 'Erro: ${e.code}';
    }
  }

  Future<String?> deleteMenu({
    required String menuId,
  }) async {
    try {
      // Excluir o documento do Firestore
      await _firestore.collection('Cardapios').doc(menuId).delete();

      await _firebaseController.deleteFolder(
          folderPath: 'cardapios/$menuId/imagens');
      await _firebaseController.deleteFolder(
          folderPath: 'cardapios/$menuId/thumbnails');

      if (kDebugMode) {
        print('deleteMenu executado');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar deleteMenu: ${e.code}');
      }
      return e.code;
    }
    return null;
  }

  Future<String?> updateMenu({
    required String menuID,
    required description,
  }) async {
    try {
      final validationDescription =
          _firebaseController.validateDescription(description);
      if (validationDescription != null) {
        return '$validationDescription Descrição do Cardápio';
      }

      await _firestore.collection('Cardapios').doc(menuID).update({
        'Descricao': description,
      });
      if (kDebugMode) {
        print('updateMenu executado');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar updateMenu: ${e.code}');
      }

      return e.code;
    }
    return null;
  }
}
