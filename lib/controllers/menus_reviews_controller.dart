import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intraflow/models/menus_reviews_model.dart';
import 'package:intraflow/services/firebase/firebase_controller.dart';

class MenusReviewsController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseController _firebaseController = FirebaseController();
  Uint8List? _imageData;

  Uint8List? get imageData => _imageData;

  set imageData(Uint8List? value) {
    _imageData = value;
    notifyListeners();
  }

  Future<List<MenusReviewsModel>> getMenusReviews() async {
    List<MenusReviewsModel> menusReviews = [];
    try {
      QuerySnapshot menusReviewsSnapshot =
          await _firestore.collectionGroup('Avaliacao').get();

      for (QueryDocumentSnapshot menusReviewsDoc in menusReviewsSnapshot.docs) {
        String idMenu = menusReviewsDoc.reference.parent.parent!.id;

        Map<String, dynamic> menusReviewsData =
            menusReviewsDoc.data() as Map<String, dynamic>;

        DocumentSnapshot menuDoc =
            await _firestore.collection('Cardapios').doc(idMenu).get();

        Map<String, dynamic> menuData = menuDoc.data() as Map<String, dynamic>;

        menusReviews.add(
          MenusReviewsModel(
            id: menusReviewsDoc.id,
            nota: menusReviewsData['Nota'],
            comentario: menusReviewsData['Comentario'],
            data: (menusReviewsData['Data'] as Timestamp).toDate(),
            idCardapios: idMenu,
            descricaoCardapio: menuData['DescricaoCardapio'],
            dataCardapio: (menuData['Data'] as Timestamp).toDate(),
            dataInicialCardapio:
                (menuData['DataInicial'] as Timestamp).toDate(),
            dataFinalCardapio: (menuData['DataFinal'] as Timestamp).toDate(),
            imagemURLCardapio: menuData['ImagemURL'],
            thumbURLCardapio: menuData['ThumbURL'],
          ),
        );
      }
      if (kDebugMode) {
        print('getMenusReviews executado');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar getMenusReviews: ${e.code}');
      }
    }
    return menusReviews;
  }

  Future<String?> postMenusReviews({
    required String idCardapio,
    required int nota,
    required String comentario,
  }) async {
    bool validaNota(int rating) {
      return rating > 0;
    }

    try {
      if (!validaNota(nota)) {
        return 'Por favor, certifique-se de avaliar o cardápio com pelo menos uma estrela.';
      }

      if (comentario.isNotEmpty &&
          _firebaseController.validateComment(
            comment: comentario,
          )) {
        return 'O comentário deve ter somente caracteres alfanuméricos.';
      }

      DocumentReference menuRef =
          _firestore.collection('Cardapios').doc(idCardapio);

      await menuRef.collection('Avaliacao').add({
        'Nota': nota,
        'Comentario': comentario,
        'Data': DateTime.now(),
      });

      if (kDebugMode) {
        print('postMenusReviews executado');
      }

      return null;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Erro ao executar postMenusReviews: ${e.code}');
      }
      return e.code;
    }
  }

  double calculateGeneralAverage({
    required List<MenusReviewsModel> menusReviews,
  }) {
    if (menusReviews.isEmpty) return 0.0;

    double generalAverage = 0.0;
    for (var review in menusReviews) {
      generalAverage += review.nota;
    }
    return generalAverage / menusReviews.length;
  }

  Map<String, List<MenusReviewsModel>> groupReviewsMenu({
    required List<MenusReviewsModel> menusReviews,
  }) {
    Map<String, List<MenusReviewsModel>> groupReviews = {};

    for (var review in menusReviews) {
      if (!groupReviews.containsKey(review.idCardapios)) {
        groupReviews[review.idCardapios] = [];
      }
      groupReviews[review.idCardapios]?.add(review);
    }

    return groupReviews;
  }

  Map<Object, double> calculateAverageMenu({
    required List<MenusReviewsModel> menusReviews,
  }) {
    if (menusReviews.isEmpty) return {};

    Map<String, List<double>> reviewsMenu = {};

    for (var review in menusReviews) {
      if (!reviewsMenu.containsKey(review.idCardapios)) {
        reviewsMenu[review.idCardapios] = [];
      }
      reviewsMenu[review.idCardapios]?.add(review.nota.toDouble());
    }

    Map<String, double> averageMenu = {};
    reviewsMenu.forEach((cardapioId, notas) {
      double total = notas.reduce((a, b) => a + b);
      double media = total / notas.length;
      averageMenu[cardapioId] = media;
    });

    return averageMenu;
  }
}
