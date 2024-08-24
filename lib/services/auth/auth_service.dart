import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intraflow/controllers/users_controller.dart';
import 'package:intraflow/services/local/local_user_controller.dart';
import 'package:intraflow/services/local/local_user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UsersController _usersController = UsersController();
  final LocalUserController _localUserController = LocalUserController();
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return 'Falha ao obter dados do usuário autenticado.';
      }

      String uid = firebaseUser.uid;
      String userEmail = firebaseUser.email ?? email;
      String name = firebaseUser.displayName ?? '';
      String photoUrl = firebaseUser.photoURL ?? '';
      LocalUserModel? existingUser = await _localUserController.getLocalUser();

      DateTime loginTime = DateTime.now();
      DateTime expirationTime = loginTime.add(const Duration(days: 3));

      if (existingUser != null && existingUser.uid == uid) {
        await _localUserController.updateLocalUserExpirationTime(
          newExpirationTime: expirationTime,
        );
      } else {
        await _localUserController.postLocalUser(
          uid: uid,
          email: userEmail,
          name: name,
          photoUrl: photoUrl,
        );
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
          return 'Credenciais inválidas.';
        case 'too-many-requests':
          return 'Houve muitas tentativas de login em um curto período. Aguarde um momento e tente novamente.';
        case 'user-disabled':
          return 'Usuário desativado.';
        case 'invalid-email':
          return 'E-mail inválido.';
        case 'user-not-found':
          return 'Usuário não cadastrado.';
        case 'wrong-password':
          return 'Senha incorreta.';
        case 'network-request-failed':
          return 'Sem conexão de internet! \n\nPor favor, verifique sua conexão com a internet e tente novamente.';
        default:
          return 'Erro desconhecido: ${e.message}';
      }
    } catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.recordError(e, stackTrace);
      }
      return 'Erro desconhecido: ${e.toString()}';
    }

    return null;
  }

  Future<String?> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(name);
        await user.sendEmailVerification();

        await _usersController.postUser(
          userId: user.uid,
          name: name,
          email: email,
        );

        return 'Cadastro realizado com sucesso. Verifique seu email para completar o cadastro.';
      } else {
        return 'Falha ao criar a conta.';
      }
    } on FirebaseAuthException catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.recordError(e, stackTrace);
      }

      switch (e.code) {
        case 'email-already-in-use':
          return 'O e-mail já está em uso.';
        case 'invalid-email':
          return 'O email fornecido é inválido.';
        case 'weak-password':
          return 'A senha fornecida é muito fraca.';
        default:
          return 'Erro: ${e.message}';
      }
    } catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.recordError(e, stackTrace);
      }
      return 'Erro desconhecido: ${e.toString()}';
    }
  }

  Future<String?> resetPassword({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.recordError(e, stackTrace);
      }

      if (e.code == 'user-not-found') {
        return 'E-mail não cadastrado.';
      }
      return 'Erro: ${e.message}';
    } catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.recordError(e, stackTrace);
      }
      return 'Erro desconhecido: ${e.toString()}';
    }

    return null;
  }

  Future<String?> logoutUser() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.recordError(e, stackTrace);
      }
      return 'Erro ao fazer logout: ${e.message}';
    } catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.recordError(e, stackTrace);
      }
      return 'Erro desconhecido: ${e.toString()}';
    }

    return null;
  }

  Future<String?> removeAccount({
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _auth.currentUser!.email!,
        password: password,
      );
      await _auth.currentUser!.delete();
    } on FirebaseAuthException catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.recordError(e, stackTrace);
      }
      switch (e.code) {
        case 'invalid-credential':
          return 'Senha incorreta.';
        case 'too-many-requests':
          return 'Houve muitas tentativas em um curto período. Aguarde um momento e tente novamente.';
        case 'wrong-password':
          return 'Senha incorreta.';
        case 'network-request-failed':
          return 'Sem conexão de internet! \n\nPor favor, verifique sua conexão com a internet e tente novamente.';
        default:
          return 'Erro: ${e.message}';
      }
    } catch (e, stackTrace) {
      if (_crashlytics.isCrashlyticsCollectionEnabled) {
        _crashlytics.recordError(e, stackTrace);
      }
      return 'Erro desconhecido: ${e.toString()}';
    }

    return null;
  }
}
