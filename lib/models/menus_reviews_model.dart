import 'package:cloud_firestore/cloud_firestore.dart';

class MenusReviewsModel {
  final String id;
  final String idCardapios;
  final int nota;
  final String comentario;
  final DateTime data;
  final String descricaoCardapio;
  final DateTime dataCardapio;
  final DateTime dataInicialCardapio;
  final DateTime dataFinalCardapio;
  final String imagemURLCardapio;
  final String thumbURLCardapio;

  MenusReviewsModel({
    required this.id,
    required this.idCardapios,
    required this.nota,
    required this.comentario,
    required this.data,
    required this.descricaoCardapio,
    required this.dataCardapio,
    required this.dataInicialCardapio,
    required this.dataFinalCardapio,
    required this.imagemURLCardapio,
    required this.thumbURLCardapio,
  });

  factory MenusReviewsModel.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> avaliacaoData = doc.data();
    String idCardapio = doc.reference.parent.parent!.id;

    return MenusReviewsModel(
      id: doc.id,
      nota: avaliacaoData['Nota'],
      comentario: avaliacaoData['Comentario'],
      data: (avaliacaoData['Data'] as Timestamp).toDate(),
      idCardapios: idCardapio,
      descricaoCardapio: avaliacaoData['DescricaoCardapio'],
      dataCardapio: (avaliacaoData['Data'] as Timestamp).toDate(),
      dataInicialCardapio: (avaliacaoData['DataInicial'] as Timestamp).toDate(),
      dataFinalCardapio: (avaliacaoData['DataFinal'] as Timestamp).toDate(),
      imagemURLCardapio: avaliacaoData['ImagemURL'],
      thumbURLCardapio: avaliacaoData['ThumbURL'],
    );
  }
}
