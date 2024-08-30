import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:intraflow/controllers/files_controller.dart';
import 'package:intraflow/models/announcements_model.dart';
import 'package:intraflow/services/firebase/firebase_controller.dart';

class AnnouncementsController extends ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FilesController _filesController = FilesController();
  final FirebaseController _firebaseController = FirebaseController();

  Future<List<AnnouncementsModel>> getAnnouncements({
    required String option,
  }) async {
    List<AnnouncementsModel> announcements = [];
    try {
      QuerySnapshot allAnnouncementsSnapshot = await _firestore
          .collection('Comunicados')
          .orderBy('Data', descending: true)
          .get();

      DateTime lastReleaseDate = DateTime.now();
      if (allAnnouncementsSnapshot.docs.isNotEmpty) {
        Map<String, dynamic>? firstAnnouncementsData =
            allAnnouncementsSnapshot.docs.first.data() as Map<String, dynamic>?;

        if (firstAnnouncementsData != null &&
            firstAnnouncementsData.containsKey('Data')) {
          lastReleaseDate =
              (firstAnnouncementsData['Data'] as Timestamp).toDate();
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

      QuerySnapshot currentAnnouncementsSnapshot = await _firestore
          .collection('Comunicados')
          .where('Data', isGreaterThanOrEqualTo: dateStart)
          .where('Data', isLessThanOrEqualTo: dateEnd)
          .orderBy('Data', descending: true)
          .get();

      Set<String> idsCurrentAnnouncements =
          currentAnnouncementsSnapshot.docs.map((doc) => doc.id).toSet();

      Future<Map<String, List<String>>> getImageUrls({
        required String docId,
      }) async {
        String refOriginal = 'comunicados/$docId/imagens/';
        String refThumb = 'comunicados/$docId/thumbnails/';

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

      for (DocumentSnapshot doc in allAnnouncementsSnapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          DateTime dataAnnouncements = (data['Data'] as Timestamp).toDate();

          if ((option == 'atuais' &&
                  idsCurrentAnnouncements.contains(doc.id)) ||
              (option == 'anteriores' &&
                  !idsCurrentAnnouncements.contains(doc.id)) ||
              (option == 'semana' &&
                  dataAnnouncements.isAfter(startWeek) &&
                  dataAnnouncements.isBefore(endWeek))) {
            Map<String, List<String>> imageUrls =
                await getImageUrls(docId: doc.id);

            announcements.add(
              AnnouncementsModel(
                id: doc.id,
                descricao: data['Descricao'],
                imagemURL: imageUrls['ImagemURLs'] ?? [],
                thumbURL: imageUrls['ThumbURLs'] ?? [],
                data: dataAnnouncements,
              ),
            );
          }
        }
      }

      if (kDebugMode) {
        print('getAnnouncements($option) executado');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar getAnnouncements($option): ${e.code}');
      }
    }

    return announcements;
  }

  Future<String?> postAnnouncement({
    required String description,
    required List<Uint8List> imageDataList,
  }) async {
    try {
      final validationDescription =
          _firebaseController.validateDescription(description);
      if (validationDescription != null) {
        return '$validationDescription Descrição do Comunicado';
      }

      // Adiciona um novo documento ao Firestore para obter o ID do documento
      DocumentReference docRef =
          await _firestore.collection('Comunicados').add({
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
            'comunicados/$docId/imagens/img-$i-${DateTime.now().toString()}.png';
        String refThumb =
            'comunicados/$docId/thumbnails/thumb-$i-${DateTime.now().toString()}.png';

        // Salva a imagem original no Firebase Storage
        await _storage.ref(refOriginal).putData(imageData);

        // Salva a imagem redimensionada no Firebase Storage
        await _storage.ref(refThumb).putData(resizedImage);

        if (kDebugMode) {
          print('postAnnouncement executado para imagem $i');
        }
      }

      return null;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar postAnnouncement: ${e.code}');
      }
      return 'Erro: ${e.code}';
    }
  }

  Future<String?> deleteAnnouncement({
    required String announcementId,
  }) async {
    try {
      // Excluir o documento do Firestore
      await _firestore.collection('Comunicados').doc(announcementId).delete();

      await _firebaseController.deleteFolder(
          folderPath: 'comunicados/$announcementId/imagens');
      await _firebaseController.deleteFolder(
          folderPath: 'comunicados/$announcementId/thumbnails');

      if (kDebugMode) {
        print('deleteAnnouncement executado');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar deleteAnnouncement: ${e.code}');
      }
      return e.code;
    }
    return null;
  }

  Future<String?> updateAnnouncement({
    required String announcementId,
    required String description,
  }) async {
    try {
      final validationDescription =
          _firebaseController.validateDescription(description);
      if (validationDescription != null) {
        return '$validationDescription Descrição do Comunicado';
      }

      await _firestore.collection('Comunicados').doc(announcementId).update({
        'Descricao': description,
      });
      if (kDebugMode) {
        print('updateAnnouncement executado');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar updateAnnouncement: ${e.code}');
      }

      return e.code;
    }
    return null;
  }
}
