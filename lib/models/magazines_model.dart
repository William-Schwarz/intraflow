import 'package:cloud_firestore/cloud_firestore.dart';

class MagazinesModel {
  String id;
  String descricao;
  String imagemURL;
  String thumbURL;
  String pdfURL;
  DateTime data;
  MagazinesModel({
    required this.id,
    required this.descricao,
    required this.imagemURL,
    required this.thumbURL,
    required this.pdfURL,
    required this.data,
  });

  factory MagazinesModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic>? data = doc.data();

    return MagazinesModel(
      id: doc.id,
      descricao: data?['Descricao'] ?? '',
      imagemURL: data?['ImagemURL'] ?? '',
      thumbURL: data?['ThumbURL'] ?? '',
      pdfURL: data?['PdfURL'] ?? '',
      data: (data?['Data'] as Timestamp).toDate(),
    );
  }
}
