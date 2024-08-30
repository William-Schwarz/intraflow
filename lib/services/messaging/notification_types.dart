import 'package:intraflow/services/messaging/send_notification_fcm.dart';

class NotificationTypes {
  static String startBody = 'Olá, Colaborador!👋';
  static String endBody = 'Vem conferir!😁';
  final SendNotification _sendNotification = SendNotification();

  Future<void> newMenuNotification({
    String? image,
  }) async {
    String title = 'Cardápio novo na área';
    String body =
        '$startBody\nPassando para te avisar que tem cardápio novo disponível. $endBody';
    await _sendNotification.sendAllDevices(
      title: title,
      body: body,
      image: image,
    );
  }

  Future<void> newMagazineNotification({
    String? image,
  }) async {
    String title = 'Revista nova na área';
    String body =
        '$startBody\nPassando para te avisar que tem revista nova disponível. $endBody';
    await _sendNotification.sendAllDevices(
      title: title,
      body: body,
      image: image,
    );
  }

  Future<void> newAnnouncementsNotification({
    String? image,
  }) async {
    String title = 'Comunicado novo na área';
    String body =
        '$startBody\nPassando para te avisar que tem comunicado novo disponível. $endBody';
    await _sendNotification.sendAllDevices(
      title: title,
      body: body,
      image: image,
    );
  }

  Future<void> newEventNotification({
    String? image,
  }) async {
    String title = 'Evento novo na área';
    String body =
        '$startBody\nPassando para te avisar que tem evento novo disponível. $endBody';
    await _sendNotification.sendAllDevices(
      title: title,
      body: body,
      image: image,
    );
  }

  Future<void> newLgpdNotification({
    String? image,
  }) async {
    String title = 'Privacidade e Segurança nova na área';
    String body =
        '$startBody\nPassando para te avisar que tem Privacidade e Segurança nova disponível. $endBody';
    await _sendNotification.sendAllDevices(
      title: title,
      body: body,
      image: image,
    );
  }

  Future<void> newCodeEthicsNotification({
    String? image,
  }) async {
    String title = 'Código de Ética novo na área';
    String body =
        '$startBody\nPassando para te avisar que tem Código de Ética novo disponível. $endBody';
    await _sendNotification.sendAllDevices(
      title: title,
      body: body,
      image: image,
    );
  }

  Future<void> newCustomNotification({
    required String title,
    required String body,
  }) async {
    await _sendNotification.sendAllDevices(
      title: title,
      body: body,
      image: '',
    );
  }
}
