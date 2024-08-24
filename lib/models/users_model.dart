import 'package:cloud_firestore/cloud_firestore.dart';

class UsersModel {
  String id;
  String email;
  String nome;
  Map<String, dynamic> roles;

  UsersModel({
    required this.id,
    required this.email,
    required this.nome,
    required this.roles,
  });

  factory UsersModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic>? data = doc.data();

    //Roles padrão
    Map<String, dynamic> defaultRoles = {
      'visualizador': {
        'eventos': false,
        'cardapios': false,
        'comunicados': false,
        'revistas': false,
        'lgpd': false,
        'codigoEtica': false,
      },
      'editor': {
        'eventos': false,
        'cardapios': false,
        'comunicados': false,
        'revistas': false,
        'lgpd': false,
        'codigoEtica': false,
        'notificacoes': false,
      },
      'administrador': {
        'usuarios': false,
      },
    };

    Map<String, dynamic> mergedRoles = {
      ...defaultRoles,
      ...?data?['Roles'],
    };

    return UsersModel(
      id: doc.id,
      email: data?['Email'] ?? '',
      nome: data?['Nome'] ?? '',
      roles: mergedRoles,
    );
  }
}
