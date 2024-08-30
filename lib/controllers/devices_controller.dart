import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:intraflow/models/devices_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DevicesController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<List<String>> getDevicesTokens([HttpRequest? request]) async {
    List<String> tokens = [];

    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('Devices').get();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot doc in querySnapshot.docs) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

          if (data != null) {
            String? token = data['Token'];
            if (token != null) {
              tokens.add(token);
            }
          }
        }
      } else {
        if (kDebugMode) {
          print('Nenhum dispositivo encontrado com o token especificado.');
        }
      }

      if (kDebugMode) {
        print('getDeviceTokens executado com sucesso.');
      }
    } on FirebaseException catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.setCustomKey('exceção_getDeviceTokens', e.toString());
        _crashlytics.recordError(e, stackTrace);
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Erro inesperado em getDeviceTokens: $e');
      }

      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.setCustomKey(
            'erro_inesperado_getDeviceTokens', e.toString());
        _crashlytics.recordError(e, stackTrace);
      }
    }

    return tokens;
  }

  Future<String?> postDevice({
    required DevicesModel device,
  }) async {
    try {
      await Firebase.initializeApp();

      CollectionReference devices = _firestore.collection('Devices');

      DocumentReference deviceRef = await devices.add({
        'Brand': device.brand,
        'Model': device.model,
        'Token': device.token,
        'Data': device.data,
      });

      if (kDebugMode) {
        print('postDevice executado');
      }
      // ignore: unnecessary_null_comparison, unrelated_type_equality_checks
      if (deviceRef != null || deviceRef == '') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('pushToken', device.token);
        prefs.setBool('tokenSent', true);
      } else {
        throw Exception('Falha ao criar o dispositivo.');
      }
    } on FirebaseException catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.setCustomKey('exceção_postDevice', e.toString());
        _crashlytics.recordError(e, stackTrace);
      }
      if (kDebugMode) {
        print('Erro ao executar postDevice: ${e.code}');
      }
    }
    return null;
  }

  Future<void> deleteDevice({
    required String token,
  }) async {
    try {
      await _firestore
          .collection('Devices')
          .where('Token', isEqualTo: token)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });
      if (kDebugMode) {
        print('Token inválido removido: $token');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao remover token inválido: $e');
      }
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.recordError(e, null,
            reason: 'Erro ao remover token inválido');
      }
    }
  }

  Future<void> updateDevice({
    required String oldToken,
    required String newToken,
  }) async {
    try {
      CollectionReference devices = _firestore.collection('Devices');

      QuerySnapshot snapshot =
          await devices.where('Token', isEqualTo: oldToken).get();

      for (DocumentSnapshot ds in snapshot.docs) {
        await ds.reference.update({
          'Token': newToken,
          'Data': DateTime.now(),
        });
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('pushToken', newToken);
      prefs.setBool('tokenSent', true);

      if (kDebugMode) {
        print('Token atualizado de $oldToken para $newToken');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar token: $e');
      }
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.recordError(e, null, reason: 'Erro ao atualizar token');
      }
    }
  }
}
