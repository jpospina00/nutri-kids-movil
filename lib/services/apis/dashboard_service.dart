import 'package:dio/dio.dart';
import 'package:nutri_kids_movil/models/user_model.dart';
import 'package:nutri_kids_movil/services/apis/dio_client.dart';
import 'package:nutri_kids_movil/services/local_storage.dart';

class DashboardService {
  final Dio _dio = DioClient.dio;
  Future<List<User?>> getUsersByUser() async {
    // Call your API to get users by userId
    try {
      String token = LocalStorage.prefs.getString('token') ?? '';
      final response = await _dio.get("/user/users-by-user", options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ));
      print("Respuesta: ${response.data}");
      List<User?> users = (response.data["users"] as List)
          .map((userData) => User.fromJson(userData))
          .toList();
      return users;
    } on DioException catch (e) {
      print("Error: ${e}");
      return [];
    }
  }

  Future<Map<String, dynamic>> generateMeals(String idUser) async {
  try {
    String token = LocalStorage.prefs.getString('token') ?? '';

    final response = await _dio.post(
      "/food/generate/$idUser",
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    print("Respuesta: ${response.data}");

    if (response.statusCode == 200) {
      // Verificamos que "meals" venga como lista
      
      return response.data;
    } else {
      print("Error: código de estado ${response.statusCode}");
      return {};
    }
  } on DioException catch (e) {
    print("Error al generar comidas: ${e.response?.data ?? e.message}");
    return {};
  } catch (e) {
    print("Error inesperado: $e");
    return {};
  }
}

}