import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class LocalAuthService {
  final _localAuth = LocalAuthentication();

  // Verifica se o dispositivo possui suporte à autenticação biométrica ou qualquer outra autenticação
  Future<bool> hasSupport({
    bool biometricOnly = true,
  }) async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final bool hasBiometrics = await _localAuth.getAvailableBiometrics().then((biometrics) => biometrics.isNotEmpty);

      // Se só biometria for permitida e não há suporte, retorna false
      if (biometricOnly) {
        return canCheckBiometrics && hasBiometrics;
      }

      // Retorna true se há suporte para biometria ou qualquer outro tipo de autenticação
      return isDeviceSupported || hasBiometrics;
    } on PlatformException catch (err) {
      if (err.code == auth_error.notAvailable || err.code == auth_error.notEnrolled) {
        // Se não há suporte ou nenhuma biometria cadastrada, retorna false
        return false;
      } else {
        // Trate outros erros conforme necessário
        return false;
      }
    }
  }

  // Autentica o usuário utilizando biometria ou outras credenciais do dispositivo
  Future<bool> authenticate({String? message, bool biometricOnly = true}) async {
    try {
      final bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Por favor, realize a autenticação',
        authMessages: [
          const AndroidAuthMessages(
            cancelButton: 'Cancelar', // Texto do botão cancelar
            signInTitle: 'Autenticação Biométrica', // Título da janela de autenticação
            biometricHint: '', // Dica durante a autenticação
            biometricNotRecognized: 'Biometria não reconhecida', // Mensagem se a biometria falhar
            biometricRequiredTitle: 'Cadastro de Biometria', // Título se a biometria for necessária
            biometricSuccess: 'Autenticado', // Mensagem se a autenticação for bem-sucedida
            deviceCredentialsRequiredTitle: '', // Título se as credenciais do dispositivo forem necessárias
            deviceCredentialsSetupDescription: '', // Descrição para configurar credenciais do dispositivo
            goToSettingsButton: 'Configurações', // Texto do botão para ir para as configurações
            goToSettingsDescription:
                'Não há nenhuma biometria cadastrada. Você deseja ir para as configurações e cadastrar uma nova?', // Descrição explicando por que ir para as configurações
          ),
          const IOSAuthMessages(
            cancelButton: 'Cancelar', // Texto do botão cancelar
            goToSettingsButton: 'Configurações', // Texto do botão para ir para as configurações
            goToSettingsDescription:
                'Por favor, configure sua biometria ou PIN.', // Descrição explicando por que ir para as configurações
          ),
        ],
        options: const AuthenticationOptions(
          biometricOnly: false, // Permite biometria ou credenciais do dispositivo
          stickyAuth: true, // Mantém a autenticação ativa até ser concluída
          useErrorDialogs: true, // Exibe diálogos de erro automaticamente
          sensitiveTransaction: false, // Indica que não é uma transação sensível
        ),
      );
      return isAuthenticated;
    } on PlatformException catch (error) {
      if (error.code == auth_error.notAvailable) {
        // Retorna false quando não há nenhum tipo de autenticação cadastrada
        return false;
      } else if (error.code == auth_error.notEnrolled) {
        // Retorna false quando nenhuma biometria está cadastrada
        return false;
      } else {
        // Retorna false para outros erros
        return false;
      }
    }
  }

  // Verifica se há biometria disponível no dispositivo
  Future<bool> hasAvailableBiometrics() async {
    return (await _localAuth.getAvailableBiometrics()).isNotEmpty;
  }
}
