import 'package:cloud_firestore/cloud_firestore.dart';

class CodeEthicsModel {
  String id;
  String descricao;
  List<String> imagemURL;
  List<String> thumbURL;
  DateTime data;
  CodeEthicsModel({
    required this.id,
    required this.descricao,
    required this.imagemURL,
    required this.thumbURL,
    required this.data,
  });

  factory CodeEthicsModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic>? data = doc.data();

    return CodeEthicsModel(
      id: doc.id,
      descricao: data?['Descricao'] ?? '',
      imagemURL: List<String>.from(data?['ImagemURL'] ?? []),
      thumbURL: List<String>.from(data?['ThumbURL'] ?? []),
      data: (data?['Data'] as Timestamp).toDate(),
    );
  }
}
