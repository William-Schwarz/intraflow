import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intraflow/constants.dart';
import 'package:intraflow/firebase_options.dart';
import 'package:intraflow/services/messaging/set_push_token.dart';
import 'package:intraflow/services/messaging/show_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StartPushNotificationHandler {
  final navigatorKey = GlobalKey<NavigatorState>();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> startPushNotificationHandler({
    required FirebaseMessaging messaging,
  }) async {
    String? token;
    try {
      if (DefaultFirebaseOptions.currentPlatform ==
          DefaultFirebaseOptions.web) {
        token = Constants.vapidKey;
      } else {
        token = await messaging.getToken();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao obter token de notificação: $e');
      }
    }
    setPushToken(token: token);

    // Monitora a atualização do token
    _messaging.onTokenRefresh.listen((newToken) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? oldToken = prefs.getString('pushToken');

      if (oldToken != newToken) {
        // Atualiza o token no Firestore
        await _firestore.collection('Devices').doc(newToken).set({
          'Token': newToken,
          // Adicione outras informações do dispositivo conforme necessário
        });

        // Remove o token antigo do Firestore
        if (oldToken != null) {
          await _firestore.collection('Devices').doc(oldToken).delete();
        }

        // Atualiza o token no SharedPreferences
        prefs.setString('pushToken', newToken);
        prefs.setBool('tokenSent', true);
      }
    });

    // Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Recebi uma mensagem enquanto estava com o App aberto');
      }
      if (kDebugMode) {
        print('Dados da mensagem: ${message.data}');
      }

      if (message.notification != null) {
        if (kDebugMode) {
          print(
              'A mensagem também continha uma notificação: ${message.notification!.title}, ${message.notification!.body}');
        }

        showNotification(
          title: message.notification!.title,
          body: message.notification!.body,
        );
      }
    });

    // Background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Terminated
    var notification = await FirebaseMessaging.instance.getInitialMessage();
    if (notification != null &&
        notification.data['message'] != null &&
        notification.data['message'].length > 0) {
      showMyDialog(notification.data[
          'message']); // Exibe essa mensagem quando o usuário clica na notificação
    }
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    if (kDebugMode) {
      print('Mensagem recebida em background: ${message.notification}');
    }
  }

// Tela de mensagem
  void showMyDialog(String message) {
    Widget okButton = OutlinedButton(
      onPressed: () => Navigator.pop(navigatorKey.currentContext!),
      child: const Text('Ok!'),
    );
    AlertDialog alerta = AlertDialog(
      title: const Text('Mensagem'),
      content: Text(message),
      actions: [
        okButton,
      ],
    );
    showDialog(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) {
          return alerta;
        });
  }
}
