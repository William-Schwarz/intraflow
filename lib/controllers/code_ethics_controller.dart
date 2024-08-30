import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:intraflow/controllers/files_controller.dart';
import 'package:intraflow/models/code_ethics_model.dart';
import 'package:intraflow/services/firebase/firebase_controller.dart';

class CodeEthicsController extends ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FilesController _filesController = FilesController();
  final FirebaseController _firebaseController = FirebaseController();

  Future<List<CodeEthicsModel>> getCodeEthics({
    required String option,
  }) async {
    List<CodeEthicsModel> codeEthics = [];
    try {
      QuerySnapshot allCodeEthisSnapshot = await _firestore
          .collection('CodigoEtica')
          .orderBy('Data', descending: true)
          .get();

      DateTime lastReleaseDate = DateTime.now();
      if (allCodeEthisSnapshot.docs.isNotEmpty) {
        Map<String, dynamic>? firstCodeEthicsData =
            allCodeEthisSnapshot.docs.first.data() as Map<String, dynamic>?;

        if (firstCodeEthicsData != null &&
            firstCodeEthicsData.containsKey('Data')) {
          lastReleaseDate = (firstCodeEthicsData['Data'] as Timestamp).toDate();
        }
      }

      DateTime dateStart = DateTime(
        lastReleaseDate.year,
        lastReleaseDate.month,
        lastReleaseDate.day,
      );

      DateTime dateEnd = DateTime(
        lastReleaseDate.year,
        lastReleaseDate.month,
        lastReleaseDate.day,
        23,
        59,
        59,
      );

      DateTime now = DateTime.now();

      DateTime startWeek = now.subtract(Duration(days: now.weekday));
      DateTime endWeek = startWeek
          .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

      QuerySnapshot currentCodeEthicsSnapshot = await _firestore
          .collection('CodigoEtica')
          .where('Data', isGreaterThanOrEqualTo: dateStart)
          .where('Data', isLessThanOrEqualTo: dateEnd)
          .orderBy('Data', descending: true)
          .get();

      Set<String> idsCurrentCodeEthics =
          currentCodeEthicsSnapshot.docs.map((doc) => doc.id).toSet();

      Future<Map<String, List<String>>> getImageUrls({
        required String docId,
      }) async {
        String refOriginal = 'codigoEtica/$docId/imagens/';
        String refThumb = 'codigoEtica/$docId/thumbnails/';

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

      for (DocumentSnapshot doc in allCodeEthisSnapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          DateTime dataCodeEthics = (data['Data'] as Timestamp).toDate();

          if ((option == 'atuais' && idsCurrentCodeEthics.contains(doc.id)) ||
              (option == 'anteriores' &&
                  !idsCurrentCodeEthics.contains(doc.id)) ||
              (option == 'semana' &&
                  dataCodeEthics.isAfter(startWeek) &&
                  dataCodeEthics.isBefore(endWeek))) {
            Map<String, List<String>> imageUrls =
                await getImageUrls(docId: doc.id);

            codeEthics.add(
              CodeEthicsModel(
                id: doc.id,
                descricao: data['Descricao'],
                imagemURL: imageUrls['ImagemURLs'] ?? [],
                thumbURL: imageUrls['ThumbURLs'] ?? [],
                data: dataCodeEthics,
              ),
            );
          }
        }
      }

      if (kDebugMode) {
        print('getCodeEthics($option) executado');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar getCodeEthics($option): ${e.code}');
      }
    }

    return codeEthics;
  }

  Future<String?> postCodeEthics({
    required String description,
    required List<Uint8List> imageDataList,
  }) async {
    try {
      final validationDescription =
          _firebaseController.validateDescription(description);
      if (validationDescription != null) {
        return '$validationDescription Descrição do Código de Ética';
      }

      // Adiciona um novo documento ao Firestore para obter o ID do documento
      DocumentReference docRef =
          await _firestore.collection('CodigoEtica').add({
        'Descricao': description,
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
            'codigoEtica/$docId/imagens/img-$i-${DateTime.now().toString()}.png';
        String refThumb =
            'codigoEtica/$docId/thumbnails/thumb-$i-${DateTime.now().toString()}.png';

        // Salva a imagem original no Firebase Storage
        await _storage.ref(refOriginal).putData(imageData);

        // Salva a imagem redimensionada no Firebase Storage
        await _storage.ref(refThumb).putData(resizedImage);

        if (kDebugMode) {
          print('postCodeEthics executado para imagem $i');
        }
      }

      return null;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar postCodeEthics: ${e.code}');
      }
      return 'Erro: ${e.code}';
    }
  }

  Future<String?> deleteCodeEthics({
    required String codeEthicsId,
  }) async {
    try {
      // Excluir o documento do Firestore
      await _firestore.collection('CodigoEtica').doc(codeEthicsId).delete();

      await _firebaseController.deleteFolder(
          folderPath: 'codigoEtica/$codeEthicsId/imagens');
      await _firebaseController.deleteFolder(
          folderPath: 'codigoEtica/$codeEthicsId/thumbnails');

      if (kDebugMode) {
        print('deleteCodeEthics executado');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar deleteCodeEthics: ${e.code}');
      }
      return e.code;
    }
    return null;
  }

  Future<String?> updateCodeEthics({
    required String codeEthicsId,
    required String description,
  }) async {
    try {
      final validationDescription =
          _firebaseController.validateDescription(description);
      if (validationDescription != null) {
        return '$validationDescription Descrição do Código de Ética';
      }

      await _firestore.collection('CodigoEtica').doc(codeEthicsId).update({
        'Descricao': description,
      });
      if (kDebugMode) {
        print('updateCodeEthics executado');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar updateCodeEthics: ${e.code}');
      }

      return e.code;
    }
    return null;
  }
}
