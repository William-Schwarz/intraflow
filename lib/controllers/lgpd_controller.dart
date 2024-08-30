import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:intraflow/controllers/files_controller.dart';
import 'package:intraflow/models/info_files.dart';
import 'package:intraflow/models/lgpd_model.dart';
import 'package:intraflow/services/firebase/firebase_controller.dart';

class LgpdController extends ChangeNotifier {
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

  Future<List<LgpdModel>> getLgpd({
    required String option,
  }) async {
    List<LgpdModel> lgpd = [];
    try {
      QuerySnapshot allLgpdSnapshot = await _firestore
          .collection('LGPD')
          .orderBy('Data', descending: true)
          .get();

      DateTime lastReleaseDate = DateTime.now();
      if (allLgpdSnapshot.docs.isNotEmpty) {
        Map<String, dynamic>? firstLgpdData =
            allLgpdSnapshot.docs.first.data() as Map<String, dynamic>?;

        if (firstLgpdData != null && firstLgpdData.containsKey('Data')) {
          lastReleaseDate = (firstLgpdData['Data'] as Timestamp).toDate();
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

      QuerySnapshot currentLgpdSnapshot = await _firestore
          .collection('LGPD')
          .where('Data', isGreaterThanOrEqualTo: dateStart)
          .where('Data', isLessThanOrEqualTo: dateEnd)
          .orderBy('Data', descending: true)
          .get();

      Set<String> idsCurrentLgpd =
          currentLgpdSnapshot.docs.map((doc) => doc.id).toSet();

      Future<Map<String, dynamic>> getFileUrls({
        required String docId,
      }) async {
        String refOriginal = 'lgpd/$docId/imagens/';
        String refThumb = 'lgpd/$docId/thumbnails/';
        String refPdfs = 'lgpd/$docId/pdfs/';

        ListResult originalImages = await _storage.ref(refOriginal).listAll();
        ListResult thumbImages = await _storage.ref(refThumb).listAll();
        ListResult pdfFiles = await _storage.ref(refPdfs).listAll();

        List<String> originalImageUrls = [];
        List<String> thumbImageUrls = [];
        String pdfUrl = '';

        for (var item in originalImages.items) {
          originalImageUrls.add(await item.getDownloadURL());
        }
        for (var item in thumbImages.items) {
          thumbImageUrls.add(await item.getDownloadURL());
        }
        if (pdfFiles.items.isNotEmpty) {
          pdfUrl = await pdfFiles.items[0].getDownloadURL();
        }

        return {
          'ImagemURLs': originalImageUrls,
          'ThumbURLs': thumbImageUrls,
          'PdfURL': pdfUrl,
        };
      }

      for (DocumentSnapshot doc in allLgpdSnapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          DateTime dataLgpd = (data['Data'] as Timestamp).toDate();

          if ((option == 'atuais' && idsCurrentLgpd.contains(doc.id)) ||
              (option == 'anteriores' && !idsCurrentLgpd.contains(doc.id)) ||
              (option == 'semana' &&
                  dataLgpd.isAfter(startWeek) &&
                  dataLgpd.isBefore(endWeek))) {
            Map<String, dynamic> fileUrls = await getFileUrls(docId: doc.id);

            lgpd.add(
              LgpdModel(
                id: doc.id,
                descricao: data['Descricao'],
                imagemURL: List<String>.from(fileUrls['ImagemURLs'] ?? []),
                thumbURL: List<String>.from(fileUrls['ThumbURLs'] ?? []),
                pdfURL: fileUrls['PdfURL'] ?? '',
                data: dataLgpd,
              ),
            );
          }
        }
      }

      if (kDebugMode) {
        print('getLgpd($option) executado');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar getLgpd($option): ${e.code}');
      }
    }

    return lgpd;
  }

  Future<String?> postLgpd({
    required String description,
    required List<Uint8List> imageDataList,
    Uint8List? pdfFile,
  }) async {
    try {
      final validationDescription =
          _firebaseController.validateDescription(description);
      if (validationDescription != null) {
        return '$validationDescription Descrição da Privacidade e Segurança';
      }

      // Adiciona um novo documento ao Firestore para obter o ID do documento
      DocumentReference docRef = await _firestore.collection('LGPD').add({
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
            'lgpd/$docId/imagens/img-$i-${DateTime.now().toString()}.png';
        String refThumb =
            'lgpd/$docId/thumbnails/thumb-$i-${DateTime.now().toString()}.png';

        // Salva a imagem original no Firebase Storage
        await _storage.ref(refOriginal).putData(imageData);

        // Salva a imagem redimensionada no Firebase Storage
        await _storage.ref(refThumb).putData(resizedImage);

        if (pdfFile != null) {
          String refPDF =
              'lgpd/$docId/pdfs/pdf-$i-${DateTime.now().toString()}.pdf';

          // Salava o pdf no Firebase Storage
          await _storage.ref(refPDF).putData(pdfFile);
        }
        if (kDebugMode) {
          print('postLgpd executado para imagem $i');
        }
      }

      return null;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar postLgpd: ${e.code}');
      }
      return 'Erro: ${e.code}';
    }
  }

  Future<String?> deleteLgpd({
    required String lgpdId,
  }) async {
    try {
      // Excluir o documento do Firestore
      await _firestore.collection('LGPD').doc(lgpdId).delete();

      await _firebaseController.deleteFolder(
          folderPath: 'lgpd/$lgpdId/imagens');
      await _firebaseController.deleteFolder(
          folderPath: 'lgpd/$lgpdId/thumbnails');
      await _firebaseController.deleteFolder(folderPath: 'gpd/$lgpdId/pdfs');

      if (kDebugMode) {
        print('deleteLgpd executado');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar deleteLgpd: ${e.code}');
      }
      return e.code;
    }
    return null;
  }

  Future<String?> updateLgpd({
    required String lgpdId,
    required String description,
  }) async {
    try {
      final validationDescription =
          _firebaseController.validateDescription(description);
      if (validationDescription != null) {
        return '$validationDescription Descrição da Privacidade e Segurança';
      }

      await _firestore.collection('LGPD').doc(lgpdId).update({
        'Descricao': description,
      });
      if (kDebugMode) {
        print('updateLGPD executado');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar updateLGPD: ${e.code}');
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
