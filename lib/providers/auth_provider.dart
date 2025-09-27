import 'package:flutter/material.dart';
import 'package:nutri_kids_movil/services/local_storage.dart';

enum AuthStatus { checking, authenticated, notAuthenticated }

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
}
