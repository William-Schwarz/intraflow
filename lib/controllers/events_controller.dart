import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:intraflow/controllers/files_controller.dart';
import 'package:intraflow/models/events_model.dart';
import 'package:intraflow/services/firebase/firebase_controller.dart';

class EventsController extends ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FilesController _filesController = FilesController();
  final FirebaseController _firebaseController = FirebaseController();

  Future<List<EventsModel>> getEvents({
    required String option,
  }) async {
    List<EventsModel> events = [];
    try {
      QuerySnapshot allEventsSnapshot = await _firestore
          .collection('Eventos')
          .orderBy('Data', descending: true)
          .get();

      DateTime lastReleaseDate = DateTime.now();
      if (allEventsSnapshot.docs.isNotEmpty) {
        Map<String, dynamic>? firstEventData =
            allEventsSnapshot.docs.first.data() as Map<String, dynamic>?;

        if (firstEventData != null && firstEventData.containsKey('Data')) {
          lastReleaseDate = (firstEventData['Data'] as Timestamp).toDate();
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

      QuerySnapshot currentEventsSnapshot = await _firestore
          .collection('Eventos')
          .where('Data', isGreaterThanOrEqualTo: dateStart)
          .where('Data', isLessThanOrEqualTo: dateEnd)
          .orderBy('Data', descending: true)
          .get();

      Set<String> idsCurrentEvents =
          currentEventsSnapshot.docs.map((doc) => doc.id).toSet();

      Future<Map<String, List<String>>> getImageUrls({
        required String docId,
      }) async {
        String refOriginal = 'eventos/$docId/imagens/';
        String refThumb = 'eventos/$docId/thumbnails/';

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

      for (DocumentSnapshot doc in allEventsSnapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          DateTime dataEvent = (data['Data'] as Timestamp).toDate();

          if ((option == 'atuais' && idsCurrentEvents.contains(doc.id)) ||
              (option == 'anteriores' && !idsCurrentEvents.contains(doc.id)) ||
              (option == 'semana' &&
                  dataEvent.isAfter(startWeek) &&
                  dataEvent.isBefore(endWeek))) {
            Map<String, List<String>> imageUrls =
                await getImageUrls(docId: doc.id);

            events.add(
              EventsModel(
                id: doc.id,
                descricao: data['Descricao'],
                imagemURL: imageUrls['ImagemURLs'] ?? [],
                thumbURL: imageUrls['ThumbURLs'] ?? [],
                data: dataEvent,
              ),
            );
          }
        }
      }

      if (kDebugMode) {
        print('getEvents($option) executado');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar getEvents($option): ${e.code}');
      }
    }

    return events;
  }

  Future<String?> postEvent({
    required String description,
    required List<Uint8List> imageDataList,
  }) async {
    try {
      final validationDescription =
          _firebaseController.validateDescription(description);
      if (validationDescription != null) {
        return '$validationDescription Descrição do Evento';
      }

      // Adiciona um novo documento ao Firestore para obter o ID do documento
      DocumentReference docRef = await _firestore.collection('Eventos').add({
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
            'eventos/$docId/imagens/img-$i-${DateTime.now().toString()}.png';
        String refThumb =
            'eventos/$docId/thumbnails/thumb-$i-${DateTime.now().toString()}.png';

        // Salva a imagem original no Firebase Storage
        await _storage.ref(refOriginal).putData(imageData);

        // Salva a imagem redimensionada no Firebase Storage
        await _storage.ref(refThumb).putData(resizedImage);

        if (kDebugMode) {
          print('postEvent executado para imagem $i');
        }
      }

      return null;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar postEvent: ${e.code}');
      }
      return 'Erro: ${e.code}';
    }
  }

  Future<String?> deleteEvent({
    required String eventId,
  }) async {
    try {
      // Excluir o documento do Firestore
      await _firestore.collection('Eventos').doc(eventId).delete();

      await _firebaseController.deleteFolder(
          folderPath: 'eventos/$eventId/imagens');
      await _firebaseController.deleteFolder(
          folderPath: 'eventos/$eventId/thumbnails');

      if (kDebugMode) {
        print('deleteEvent executado');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar deleteEvent: ${e.code}');
      }
      return e.code;
    }
    return null;
  }

  Future<String?> updateEvent({
    required String eventId,
    required String description,
  }) async {
    try {
      final validationDescription =
          _firebaseController.validateDescription(description);
      if (validationDescription != null) {
        return '$validationDescription Descrição do Evento';
      }

      await _firestore.collection('Eventos').doc(eventId).update({
        'Descricao': description,
      });
      if (kDebugMode) {
        print('updateEvent executado');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar updateEvent: ${e.code}');
      }

      return e.code;
    }
    return null;
  }
}
