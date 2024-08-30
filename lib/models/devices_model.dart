import 'package:cloud_firestore/cloud_firestore.dart';

class DevicesModel {
  String brand;
  String model;
  String token;
  DateTime data;
  DevicesModel({
    required this.brand,
    required this.model,
    required this.token,
    required this.data,
  });

  factory DevicesModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic>? data = doc.data();

    return DevicesModel(
      brand: data?['Brand'] ?? '',
      model: data?['Model'] ?? '',
      token: data?['Token'] ?? '',
      data: (data?['Data'] as Timestamp).toDate(),
    );
  }
}
