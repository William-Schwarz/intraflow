import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:intraflow/controllers/files_controller.dart';
import 'package:intraflow/models/info_files.dart';
import 'package:intraflow/models/magazines_model.dart';
import 'package:intraflow/services/firebase/firebase_controller.dart';

class MagazinesController extends ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FilesController _filesController = FilesController();
  final FirebaseController _firebaseController = FirebaseController();

  Uint8List? _imageData;
  InfoFilesModel? _pdfInfo;

  Uint8List? get imageData => _imageData;
  InfoFilesModel? get pdfInfo => _pdfInfo;

  set imageData(Uint8List? value) {
    _imageData = value;
    notifyListeners();
  }

  set pdfInfo(InfoFilesModel? value) {
    _pdfInfo = value;
    notifyListeners();
  }

  Future<List<MagazinesModel>> getMagazines({
    required String option,
  }) async {
    List<MagazinesModel> magazines = [];
    try {
      QuerySnapshot allMagazinesSnapshot = await _firestore
          .collection('Revistas')
          .orderBy('Data', descending: true)
          .get();

      DateTime lastReleaseDate = DateTime.now();
      if (allMagazinesSnapshot.docs.isNotEmpty) {
        Map<String, dynamic>? firstMagazineData =
            allMagazinesSnapshot.docs.first.data() as Map<String, dynamic>?;

        if (firstMagazineData != null &&
            firstMagazineData.containsKey('Data')) {
          lastReleaseDate = (firstMagazineData['Data'] as Timestamp).toDate();
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

      QuerySnapshot currentMagazinesSnapshot = await _firestore
          .collection('Revistas')
          .where('Data', isGreaterThanOrEqualTo: dateStart)
          .where('Data', isLessThanOrEqualTo: dateEnd)
          .orderBy('Data', descending: true)
          .get();

      Set<String> idsCurrentMagazines =
          currentMagazinesSnapshot.docs.map((doc) => doc.id).toSet();

      Future<Map<String, String>> getImageUrls({
        required String docId,
      }) async {
        // Define as referências para as imagens no Storage
        String refOriginal = 'revistas/$docId/imagens/';
        String refThumb = 'revistas/$docId/thumbnails/';
        String refPdfs = 'revistas/$docId/pdfs/';

        ListResult originalImages = await _storage.ref(refOriginal).listAll();
        ListResult thumbImages = await _storage.ref(refThumb).listAll();
        ListResult pdfFiles = await _storage.ref(refPdfs).listAll();

        String imageURL = '';
        String thumbURL = '';
        String pdfURL = '';

        if (originalImages.items.isNotEmpty) {
          imageURL = await originalImages.items[0].getDownloadURL();
        }
        if (thumbImages.items.isNotEmpty) {
          thumbURL = await thumbImages.items[0].getDownloadURL();
        }
        if (pdfFiles.items.isNotEmpty) {
          pdfURL = await pdfFiles.items[0].getDownloadURL();
        }

        return {
          'ImagemURL': imageURL,
          'ThumbURL': thumbURL,
          'PdfURL': pdfURL,
        };
      }

      for (DocumentSnapshot doc in allMagazinesSnapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          DateTime dataRevista = (data['Data'] as Timestamp).toDate();

          if ((option == 'atuais' && idsCurrentMagazines.contains(doc.id)) ||
              (option == 'anteriores' &&
                  !idsCurrentMagazines.contains(doc.id)) ||
              (option == 'semana' &&
                  dataRevista.isAfter(startWeek) &&
                  dataRevista.isBefore(endWeek))) {
            Map<String, String> imageUrls = await getImageUrls(docId: doc.id);
            magazines.add(
              MagazinesModel(
                id: doc.id,
                descricao: data['Descricao'],
                imagemURL: imageUrls['ImagemURL'] ?? '',
                thumbURL: imageUrls['ThumbURL'] ?? '',
                pdfURL: imageUrls['PdfURL'] ?? '',
                data: (data['Data'] as Timestamp).toDate(),
              ),
            );
          }
        }
      }

      if (kDebugMode) {
        print('getMagazines($option) executado');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar getMagazines($option): ${e.code}');
      }
    }

    return magazines;
  }

  Future<String> postMagazine({
    required String description,
    required Uint8List imageData,
    required Uint8List pdfFile,
  }) async {
    try {
      final validationDescription =
          _firebaseController.validateDescription(description);
      if (validationDescription != null) {
        return '$validationDescription Descrição da Revista';
      }

      // Adiciona um novo documento ao Firestore para obter o ID do documento
      DocumentReference docRef = await _firestore.collection('Revistas').add({
        'Descricao': description,
        'Data': DateTime.now(),
      });

      // Obtém o ID do documento
      String docId = docRef.id;

      // Redimensiona a imagem
      Uint8List resizedImage = await _filesController.resizeImage(
          imageData: imageData, width: 200, height: 250);

      // Define as referências para as imagens e o PDF no Storage
      String refOriginal =
          'revistas/$docId/imagens/img-${DateTime.now().toIso8601String()}.png';
      String refThumb =
          'revistas/$docId/thumbnails/thumb-${DateTime.now().toIso8601String()}.png';
      String refPdf =
          'revistas/$docId/pdfs/pdf-${DateTime.now().toIso8601String()}.pdf';

      // Salva a imagem original no Firebase Storage
      await _storage.ref(refOriginal).putData(imageData);

      // Salva a imagem redimensionada no Firebase Storage
      await _storage.ref(refThumb).putData(resizedImage);

      // Salva o PDF no Firebase Storage
      await _storage.ref(refPdf).putData(pdfFile);

      // Obtém a URL da imagem original
      String imageDownloadURL =
          await _storage.ref(refOriginal).getDownloadURL();

      if (kDebugMode) {
        print('postMagazine executado');
      }

      // Retorna a URL da imagem original
      return imageDownloadURL;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar postMagazine: ${e.code}');
      }
      return 'Erro: ${e.code}';
    }
  }

  Future<String?> deleteMagazine({
    required String magazineId,
  }) async {
    try {
      // Excluir o documento do Firestore
      await _firestore.collection('Revistas').doc(magazineId).delete();

      await _firebaseController.deleteFolder(
          folderPath: 'revistas/$magazineId/imagens');
      await _firebaseController.deleteFolder(
          folderPath: 'revistas/$magazineId/thumbnails');
      await _firebaseController.deleteFolder(
          folderPath: 'revistas/$magazineId/pdfs');

      if (kDebugMode) {
        print('deleteMagazine executado');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar deleteMagazine: ${e.code}');
      }
      return e.code;
    }
    return null;
  }

  Future<String?> updateRevista(
    String magazineId,
    String description,
  ) async {
    try {
      final validationDescription =
          _firebaseController.validateDescription(description);
      if (validationDescription != null) {
        return '$validationDescription Descrição da Revista';
      }

      await _firestore.collection('Revistas').doc(magazineId).update({
        'Descricao': description,
      });
      if (kDebugMode) {
        print('updateRevista executado');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar updateRevista: ${e.code}');
      }

      return e.code;
    }
    return null;
  }

  // Métodos auxiliares
  Future<void> pickImage() async {
    _imageData = await _filesController.pickImage();
    notifyListeners();
  }

  Future<void> pickPDF() async {
    _pdfInfo = await _filesController.pickPDF();
    notifyListeners();
  }
}
