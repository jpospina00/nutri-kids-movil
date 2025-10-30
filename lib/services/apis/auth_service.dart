import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nutri_kids_movil/models/user_model.dart';
import 'package:nutri_kids_movil/providers/auth_provider.dart';
import 'package:nutri_kids_movil/services/apis/dashboard_service.dart';
import 'package:nutri_kids_movil/services/apis/dio_client.dart';
import 'package:nutri_kids_movil/services/hive_services.dart';
import 'package:nutri_kids_movil/services/local_storage.dart';
import 'package:nutri_kids_movil/services/navigation_services.dart';
import 'package:provider/provider.dart';

class AuthService {
  final Dio _dio = DioClient.dio;

  /// Enviar correo para restablecer contraseña
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        "/auth/forgot-password",
        data: {"email": email},
      );
      print("Respuesta: ${response.data}");
      return response.data["ok"] ?? false;
    } on DioException catch (e) {
      print("Error: ${e}");
      return false;
    }
  }

  Future<bool> verifyPin(String email, String pin) async {
    try {
      final response = await _dio.post(
        "/auth/verify-pin",
        data: {"email": email, "pin": pin},
      );
      print("Respuesta: ${response.data}");
      return response.data["ok"] ?? false;
    } on DioException catch (e) {
      print("Error: ${e}");
      return false;
    }
  }

  /// Restablecer contraseña con token
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final response = await _dio.post(
        "/auth/reset-password",
        data: {"newPassword": newPassword, "email": email},
      );
      print("Respuesta: ${response.data}");
      return response.data["ok"] ?? false;
    } on DioException catch (e) {
      print("Error: ${e}");
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        "/auth/login",
        data: {"email": email, "password": password},
      );
      if (response.data["token"] != null) {
        HiveServices hiveServices = HiveServices();
        Map<String, dynamic> userMap =
            response.data["user"] as Map<String, dynamic>;

        await hiveServices.saveData('user', userMap);
        LocalStorage.prefs.setString(
          'selectedUser',
          response.data["user"]["name"],
        );

        BuildContext cdx = NavigationService.navigatorKey.currentContext!;
        await cdx.read<AuthProvider>().login(response.data["token"]);
        
      }
      return response.data["ok"] ?? false;
    } on DioException catch (e) {
      print("Error: ${e}");
      return false;
    }
  }

  Future<bool> register(
    String email,
    String password,
    String name,
    String lastName,
    int age,
  ) async {
    try {
      final response = await _dio.post(
        "/auth/register",
        data: {
          "email": email,
          "password": password,
          "name": name,
          "lastName": lastName,
          "age": age,
        },
      );
      print("Respuesta: ${response.data}");
      return response.data["ok"] ?? false;
    } on DioException catch (e) {
      print("Error: ${e}");
      return false;
    }
  }
}
