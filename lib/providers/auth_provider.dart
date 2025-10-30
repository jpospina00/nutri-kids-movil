import 'package:flutter/material.dart';
import 'package:nutri_kids_movil/models/user_model.dart';
import 'package:nutri_kids_movil/services/apis/dashboard_service.dart';
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

  Future<void> login(String token) async {
    LocalStorage.prefs.setString('token', token);
    _status = AuthStatus.authenticated;
    print('Auth Status: $_status');
    DashboardService dashboardService = DashboardService();
    HiveServices hiveServices = HiveServices();
    List<User?> users = await dashboardService.getUsersByUser();
    List<Map<String, dynamic>> usersList = users
        .map((u) => u!.toJson())
        .toList();
    print('Usuarios obtenidos: $usersList');

    // Guardamos directamente la lista
    await hiveServices.saveData('users', usersList);
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
