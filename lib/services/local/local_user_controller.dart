import 'package:flutter/foundation.dart';
import 'package:intraflow/services/local/local_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalUserController extends ChangeNotifier {
  LocalUserModel? _user;

  LocalUserModel? get user => _user;
  String? get photoUrl => _user?.photoUrl;

  Future<void> loadUser() async {
    _user = await getLocalUser();
    notifyListeners();
  }

  Future<LocalUserModel?> getLocalUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userJson = prefs.getString('user_auth');

      if (userJson != null) {
        if (kDebugMode) {
          print('getLocalUser executado');
        }
        return LocalUserModel.fromJson(userJson);
      } else {
        if (kDebugMode) {
          print('getLocalUser retornou nulo');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('erro ao executar getLocalUser');
      }
      return null;
    }
  }

  Future<void> postLocalUser({
    required String uid,
    required String email,
    required String name,
    required String? photoUrl,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      DateTime loginTime = DateTime.now();
      DateTime expirationTime = loginTime.add(const Duration(days: 3));

      LocalUserModel userAuth = LocalUserModel(
        uid: uid,
        email: email,
        name: name,
        expirationTime: expirationTime,
        photoUrl: photoUrl,
      );

      await prefs.setString('user_auth', userAuth.toJson());
      _user = userAuth;
      notifyListeners();
      if (kDebugMode) {
        print('getLocalUser executado');
      }
    } catch (e) {
      if (kDebugMode) {
        print('erro ao executar getLocalUser');
      }
    }
  }

  Future<void> updateLocalUserPhotoUrl({
    required String newPhotoUrl,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userAuthJson = prefs.getString('user_auth');

      if (userAuthJson != null) {
        LocalUserModel userAuth = LocalUserModel.fromJson(userAuthJson);

        LocalUserModel updatedUserAuth = LocalUserModel(
          uid: userAuth.uid,
          email: userAuth.email,
          name: userAuth.name,
          photoUrl: newPhotoUrl,
          expirationTime: userAuth.expirationTime,
        );

        await prefs.setString('user_auth', updatedUserAuth.toJson());
        _user = updatedUserAuth;
        notifyListeners();
        if (kDebugMode) {
          print('updateLocalUserPhotoUrl executado');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('updateLocalUserPhotoUrl executado');
      }
      if (kDebugMode) {
        print('erro ao executar updateLocalUserPhotoUrl');
      }
    }
  }

  Future<void> updateLocalUserExpirationTime({
    required DateTime newExpirationTime,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userAuthJson = prefs.getString('user_auth');

      if (userAuthJson != null) {
        LocalUserModel userAuth = LocalUserModel.fromJson(userAuthJson);

        LocalUserModel updatedUserAuth = LocalUserModel(
          uid: userAuth.uid,
          email: userAuth.email,
          name: userAuth.name,
          photoUrl: userAuth.photoUrl,
          expirationTime: newExpirationTime,
        );

        await prefs.setString('user_auth', updatedUserAuth.toJson());
        _user = updatedUserAuth;
        notifyListeners();
        if (kDebugMode) {
          print('updateLocalUserExpirationTime executado');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('erro ao executar updateLocalUserExpirationTime');
      }
    }
  }

  Future<void> deleteLocalUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_auth');
    _user = null;
    notifyListeners();
  }
}
