import 'package:dio/dio.dart';
import 'package:nutri_kids_movil/services/apis/dio_client.dart';

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
  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      final response = await _dio.post(
        "/auth/reset-password",
        data: {"newPassword": newPassword},
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
      print("Respuesta: ${response.data}");
      return response.data["ok"] ?? false;
    } on DioException catch (e) {
      print("Error: ${e}");
      return false;
    }
  }
}