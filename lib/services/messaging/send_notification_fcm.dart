import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intraflow/controllers/devices_controller.dart';
import 'package:intraflow/services/firebase/access_firebase_token.dart';
import 'package:intraflow/utils/helpers/app_config.dart';

class SendNotification {
  final DevicesController _devicesController = DevicesController();
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<void> sendAllDevices({
    required String title,
    required String body,
    String? image,
  }) async {
    try {
      AccessTokenFirebase accessTokenGetter = AccessTokenFirebase();
      String tokenAccess = await accessTokenGetter.getAccessToken();

      if (AppConfig().sendNotification) {
        List<String> tokens = await _devicesController.getDevicesTokens();

        for (String token in tokens) {
          Map<String, dynamic> notification = {
            'title': title,
            'body': body,
          };

          if (image != null && image.isNotEmpty) {
            notification['image'] = image;
          }

          Map<String, dynamic> data = {
            'story_id': 'story_12345',
          };

          Map<String, dynamic> message = {
            'token': token,
            'notification': notification,
            'data': data,
            'apns': {
              'headers': {
                'apns-priority': '10',
              },
              'payload': {
                'aps': {
                  'alert': notification,
                  'sound': 'default',
                  'badge': 1,
                },
              },
            },
          };

          String jsonRequest = jsonEncode({'message': message});

          http.Response response = await http.post(
            Uri.parse(
                'https://fcm.googleapis.com/v1/projects/k1-informa/messages:send'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $tokenAccess',
            },
            body: jsonRequest,
          );

          if (response.statusCode == 200) {
            if (kDebugMode) {
              print(
                  'Notificação enviada com sucesso para o dispositivo: $token');
            }
          } else {
            if (response.statusCode == 404 || response.statusCode == 410) {
              // Token is invalid, remove it from Firestore
              await _devicesController.deleteDevice(token: token);
            }

            if (_crashlytics.isCrashlyticsCollectionEnabled) {
              _crashlytics.log(
                  'Falha ao enviar notificação para o dispositivo: $token. Código de status: ${response.statusCode}');

              _crashlytics.recordError(
                'Código de status: ${response.statusCode}',
                null,
                reason: 'Erro de notificação',
              );
            }
            if (kDebugMode) {
              print(
                  'Falha ao enviar notificação para o dispositivo: $token. Código de status: ${response.statusCode}');
            }
          }
        }
      } else {
        if (kDebugMode) {
          print('Notificações desativadas');
        }
      }
    } catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.recordError(e, stackTrace,
            reason: 'Erro ao enviar notificações');
      }
      if (kDebugMode) {
        print('Erro ao enviar notificações: $e');
      }
    }
  }
}
