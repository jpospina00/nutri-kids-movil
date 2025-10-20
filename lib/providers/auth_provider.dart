import 'package:flutter/material.dart';
import 'package:nutri_kids_movil/services/hive_services.dart';
import 'package:nutri_kids_movil/services/local_storage.dart';

enum AuthStatus { checking, authenticated, notAuthenticated, filledProfile }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.checking;

  AuthStatus get authStatus => _status;

  AuthProvider() {
    isAuthenticated();
  }

  Future<bool> isAuthenticated() async {
    final token = LocalStorage.prefs.getString('token');
    if (token == null) {
      _status = AuthStatus.notAuthenticated;
      notifyListeners();
      return false;
    } else {

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
      
    }
  }



  void login(String token) {
    LocalStorage.prefs.setString('token', token);
    _status = AuthStatus.authenticated;
    print('Auth Status: $_status');
    notifyListeners();
  }

  void logout() {
    HiveServices hiveServices = HiveServices();
    hiveServices.clearBox();
    LocalStorage.prefs.remove('token');
    _status = AuthStatus.notAuthenticated;
    notifyListeners();
  }
}
