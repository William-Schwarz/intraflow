import 'package:cloud_firestore/cloud_firestore.dart';

class MenusSchedulingModel {
  String? uid;
  String nome;
  int cracha;
  DateTime data;

  MenusSchedulingModel({
    this.uid,
    required this.nome,
    required this.cracha,
    required this.data,
  });

  factory MenusSchedulingModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic>? data = doc.data();

    return MenusSchedulingModel(
      uid: data?['UID'] ?? '',
      nome: data?['Nome'] ?? '',
      cracha: data?['Cracha'] ?? 0,
      data: (data?['Data'] as Timestamp).toDate(),
    );
  }
}
