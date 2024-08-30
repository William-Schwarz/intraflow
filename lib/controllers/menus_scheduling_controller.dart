import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:intraflow/models/menus_scheduling_model.dart';

class MenusSchedulingController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<List<MenusSchedulingModel>> getMenusScheduling() async {
    List<MenusSchedulingModel> menusScheduling = [];
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('AgendamentosCardapios').get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          menusScheduling.add(
            MenusSchedulingModel(
              nome: data['Nome'],
              cracha: data['Cracha'],
              data: (data['Data'] as Timestamp).toDate(),
            ),
          );
        }
      }

      if (kDebugMode) {
        print('getMenusScheduling executado com sucesso');
      }
    } on FirebaseException catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.setCustomKey('exceção_getMenusScheduling', e.toString());
        _crashlytics.recordError(e, stackTrace);
      }
      if (kDebugMode) {
        print('Erro ao executar getMenusScheduling: ${e.code}');
      }
    }
    return menusScheduling;
  }

  Future<List<MenusSchedulingModel>> getMenuScheduling({
    required String uid,
  }) async {
    List<MenusSchedulingModel> menuScheduling = [];
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('AgendamentosCardapios').doc(uid).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          menuScheduling.add(
            MenusSchedulingModel(
              nome: data['Nome'],
              cracha: data['Cracha'],
              data: (data['Data'] as Timestamp).toDate(),
            ),
          );
        }
      }

      if (kDebugMode) {
        print('getMenuScheduling executado com sucesso');
      }
    } on FirebaseException catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.setCustomKey('exceção_getMenuScheduling', e.toString());
        _crashlytics.recordError(e, stackTrace);
      }
      if (kDebugMode) {
        print('Erro ao executar getMenuScheduling: ${e.code}');
      }
    }
    return menuScheduling;
  }

  Future<String?> postMenusScheduling({
    required MenusSchedulingModel menusScheduling,
  }) async {
    try {
      DocumentReference menusSchedulingRef = _firestore
          .collection('AgendamentosCardapios')
          .doc(menusScheduling.uid);

      // Extrair apenas a data (ignorar a hora)
      DateTime onlyDate = DateTime(menusScheduling.data.year,
          menusScheduling.data.month, menusScheduling.data.day);

      await menusSchedulingRef.set({
        'Nome': menusScheduling.nome,
        'Cracha': menusScheduling.cracha,
        'Data': onlyDate,
      });

      if (kDebugMode) {
        print('postMenusScheduling executado com sucesso');
      }
    } on FirebaseException catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.setCustomKey('exceção_postMenusScheduling', e.toString());
        _crashlytics.recordError(e, stackTrace);
      }
      if (kDebugMode) {
        print('Erro ao executar postMenusScheduling: ${e.code}');
      }
      return 'Ocorreu um erro ao agendar!';
    }
    return null;
  }

  Future<String?> deleteMenuScheduling({
    required String uid,
  }) async {
    try {
      await _firestore.collection('AgendamentosCardapios').doc(uid).delete();

      if (kDebugMode) {
        print('deleteMenuScheduling executado com sucesso');
      }
    } on FirebaseException catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.setCustomKey('exceção_deleteMenuScheduling', e.toString());
        _crashlytics.recordError(e, stackTrace);
      }
      if (kDebugMode) {
        print('Erro ao executar deleteMenuScheduling: ${e.code}');
      }
      return 'Ocorreu um erro ao excluir o agendamento!';
    }
    return null;
  }
}
