import 'package:cloud_firestore/cloud_firestore.dart';

class LgpdModel {
  String id;
  String descricao;
  List<String> imagemURL;
  List<String> thumbURL;
  String? pdfURL;
  DateTime data;
  LgpdModel({
    required this.id,
    required this.descricao,
    required this.imagemURL,
    required this.thumbURL,
    this.pdfURL,
    required this.data,
  });

  factory LgpdModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic>? data = doc.data();

    return LgpdModel(
      id: doc.id,
      descricao: data?['Descricao'] ?? '',
      imagemURL: List<String>.from(data?['ImagemURL'] ?? []),
      thumbURL: List<String>.from(data?['ThumbURL'] ?? []),
      pdfURL: data?['pdfURL'] ?? '',
      data: (data?['Data'] as Timestamp).toDate(),
    );
  }
}
