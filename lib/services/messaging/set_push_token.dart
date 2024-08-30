import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:intraflow/controllers/devices_controller.dart';
import 'package:intraflow/models/devices_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> setPushToken({
  String? token,
}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? prefsToken = prefs.getString('pushToken');
  bool? prefSent = prefs.getBool('tokenSent');
  if (kDebugMode) {
    print('Prefs Token: $prefsToken');
  }

  if (prefsToken != token || (prefsToken == token && prefSent == false)) {
    if (kDebugMode) {
      print('Salvando Token.');
    }
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? brand;
    String? model;
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        if (kDebugMode) {
          print('Rodando no ${androidInfo.model}');
        }
        brand = androidInfo.brand;
        model = androidInfo.model;
      } else {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        if (kDebugMode) {
          print('Rodando no ${iosInfo.utsname.machine}');
        }
        brand = iosInfo.utsname.machine;
        model = 'Apple';
      }

      DevicesModel device = DevicesModel(
        brand: brand,
        model: model,
        token: token!,
        data: DateTime.now(),
      );

      DevicesController devicesController = DevicesController();

      if (prefsToken != null && prefsToken.isNotEmpty) {
        // Atualiza o token existente
        await devicesController.updateDevice(
            oldToken: prefsToken, newToken: token);
      } else {
        // Adiciona um novo token
        await devicesController.postDevice(device: device);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao configurar o token de push: $e');
      }
    }
  }
}
