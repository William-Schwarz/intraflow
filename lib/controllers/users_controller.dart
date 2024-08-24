import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:intraflow/models/users_model.dart';

class UsersController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<List<UsersModel>> getUsers() async {
    List<UsersModel> users = [];

    try {
      QuerySnapshot querySnapshot = await _firestore.collection('Usuarios').orderBy('Nome', descending: false).get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          Map<String, dynamic> roles = {
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

          if (data['Roles'] != null) {
            Map<String, dynamic> rolesData = data['Roles'] as Map<String, dynamic>;
            rolesData.forEach((key, value) {
              if (value is Map<String, dynamic>) {
                roles[key] = Map<String, bool>.from(value);
              }
            });
          }

          users.add(
            UsersModel(
              id: doc.id,
              nome: data['Nome'],
              email: data['Email'],
              roles: roles,
            ),
          );
        }
      }

      if (kDebugMode) {
        print('getUsers executado');
      }
    } on FirebaseException catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.setCustomKey('exceção_getUsers', e.toString());
        _crashlytics.recordError(e, stackTrace);
      }
      if (kDebugMode) {
        print('Erro ao executar getUsers: ${e.code}');
      }
    }

    return users;
  }

  Future<String?> updateUser({
    required String uid,
    required Map<String, dynamic> roles,
  }) async {
    try {
      await _firestore.collection('Usuarios').doc(uid).update({
        'Roles': roles,
      });

      if (kDebugMode) {
        print('updateUser executado');
      }

      return null;
    } on FirebaseException catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.setCustomKey('exceção_updateUser', e.toString());
        _crashlytics.recordError(e, stackTrace);
      }

      if (kDebugMode) {
        print('Erro ao executar updateUser: ${e.code}');
      }

      return e.code;
    }
  }

  Future<int?> getUserBadge({
    required String uid,
  }) async {
    DocumentSnapshot documentSnapshot = await _firestore.collection('Usuarios').doc(uid).get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> userData = documentSnapshot.data() as Map<String, dynamic>;
      return userData['Cracha'] as int?;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserRoles({
    required String uid,
  }) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await _firestore.collection('Usuarios').doc(uid).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() ?? {};
        Map<String, dynamic> roles = {};

        if (data['Roles'] != null && data['Roles'] is Map<String, dynamic>) {
          Map<String, dynamic> dataRoles = data['Roles'];

          // Verificando e adicionando visualizador, administrador e editor, se disponíveis
          if (dataRoles['visualizador'] != null && dataRoles['visualizador'] is Map<String, dynamic>) {
            roles['visualizador'] = Map<String, dynamic>.from(dataRoles['visualizador']);
          }
          if (dataRoles['administrador'] != null && dataRoles['administrador'] is Map<String, dynamic>) {
            roles['administrador'] = Map<String, dynamic>.from(dataRoles['administrador']);
          }
          if (dataRoles['editor'] != null && dataRoles['editor'] is Map<String, dynamic>) {
            roles['editor'] = Map<String, dynamic>.from(dataRoles['editor']);
          }
        }

        // Verificando se algum papel foi encontrado
        if (roles.isNotEmpty) {
          if (kDebugMode) {
            print('Roles: $roles');
          } // Print dos papéis aqui
          return roles;
        } else {
          if (kDebugMode) {
            print('Nenhum papel encontrado para o usuário');
          }
          return null;
        }
      } else {
        if (kDebugMode) {
          print('Documento não encontrado para o usuário com UID: $uid');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao obter papéis do usuário: $e');
      }
      return null;
    }
  }

  Future<String?> postUser({
    required String userId,
    required String name,
    required String email,
  }) async {
    try {
      DocumentReference<Map<String, dynamic>> user = _firestore.collection('Usuarios').doc(userId);
      await user.set({
        'Nome': name,
        'Email': email,
        'Roles': {
          'visualizador': {
            'eventos': true,
            'cardapios': true,
            'comunicados': true,
            'revistas': true,
            'lgpd': true,
            'codigoEtica': true,
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
        },
      });

      if (kDebugMode) {
        print('postUser executado');
      }
    } on FirebaseException catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.setCustomKey('exceção_postUser', e.toString());
        _crashlytics.recordError(e, stackTrace);
      }
      if (kDebugMode) {
        print('Erro ao executar postUser: ${e.code}');
      }
    }
    return null;
  }
}
