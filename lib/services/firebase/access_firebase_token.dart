import 'package:googleapis_auth/auth_io.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intraflow/services/firebase/firebase_controller.dart';

class AccessTokenFirebase {
  final FirebaseController _firebaseController = FirebaseController();
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  static String firebaseMessagingScop =
      'https://www.googleapis.com/auth/firebase.messaging';

  Future<String> getAccessToken() async {
    try {
      // Carrega o JSON e converte para o modelo ServiceAccountModel
      final serviceAccountModel = await _firebaseController.loadJsonData();

      final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
          "type": serviceAccountModel.type,
          "project_id": serviceAccountModel.projectId,
          "private_key_id": serviceAccountModel.privateKeyId,
          "private_key": serviceAccountModel.privateKey,
          "client_email": serviceAccountModel.clientEmail,
          "client_id": serviceAccountModel.clientId,
          "auth_uri": serviceAccountModel.authUri,
          "token_uri": serviceAccountModel.tokenUri,
          "auth_provider_x509_cert_url":
              serviceAccountModel.authProviderX509CertUrl,
          "client_x509_cert_url": serviceAccountModel.clientX509CertUrl,
        }),
        [firebaseMessagingScop],
      );

      final accessToken = client.credentials.accessToken.data;
      return accessToken;
    } catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.setCustomKey('exceção_getAccessToken', e.toString());
        _crashlytics.recordError(e, stackTrace);
      }
      return 'Falha ao obter o token de acesso: ${e.toString()}';
    }
  }
}
