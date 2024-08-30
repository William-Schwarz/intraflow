import 'package:cloud_firestore/cloud_firestore.dart';

class MenusModel {
  String id;
  String descricao;
  DateTime dataInicial;
  DateTime dataFinal;
  List<String> imagemURL;
  List<String> thumbURL;
  DateTime data;

  MenusModel({
    required this.id,
    required this.descricao,
    required this.dataInicial,
    required this.dataFinal,
    required this.imagemURL,
    required this.thumbURL,
    required this.data,
  });

  factory MenusModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic>? data = doc.data();

    return MenusModel(
      id: doc.id,
      descricao: data?['Descricao'] ?? '',
      dataInicial: (data?['DataInicial'] as Timestamp).toDate(),
      dataFinal: (data?['DataFinal'] as Timestamp).toDate(),
      imagemURL: List<String>.from(data?['ImagemURL'] ?? []),
      thumbURL: List<String>.from(data?['ThumbURL'] ?? []),
      data: (data?['Data'] as Timestamp).toDate(),
    );
  }
}
