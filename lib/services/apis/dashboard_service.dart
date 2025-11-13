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
      print('Token en getUsersByUser: $token');
      final response = await _dio.get(
        "/user/users-by-user",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
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
        options: Options(headers: {'Authorization': 'Bearer $token'}),
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

  Future<Map<String, dynamic>> getMeals(String idUser) async {
    try {
      String token = LocalStorage.prefs.getString('token') ?? '';

      final response = await _dio.get(
        "/food/plan/$idUser",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print("Respuesta: ${response.data}");

      if (response.statusCode == 200) {
        return response.data;
      } else {
        print("Error: código de estado ${response.statusCode}");
        return {};
      }
    } on DioException catch (e) {
      print(
        "Error al obtener detalle de la comida: ${e.response?.data ?? e.message}",
      );
      return {};
    } catch (e) {
      print("Error inesperado: $e");
      return {};
    }
  }

  Future<void> likeOrDislikeMeal(
    String userId,
    List<String> meal,
    bool isLike,
  ) async {
    try {
      String token = LocalStorage.prefs.getString('token') ?? '';

      final response = await _dio.patch(
        "/user/$userId/ingredient-preference",
        data: {'ingredients': meal, 'action': isLike ? 'like' : 'dislike'},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print("Respuesta feedback: ${response.data}");
    } on DioException catch (e) {
      print(
        "Error al enviar feedback de la comida: ${e.response?.data ?? e.message}",
      );
    } catch (e) {
      print("Error inesperado: $e");
    }
  }

  Future<String?> createUser(
    String name,
    String lastName,
    int age,
    double height,
    double weight,
    String activityLevel,
    String goal,
    List<String> allergies,
    List<String> likes,
    List<String> dislikes,
  ) async {
    // Call your API to create a user
    try {
      String token = LocalStorage.prefs.getString('token') ?? '';
      print('Token en createUser: $token');
      final response = await _dio.post(
        "/user/",
        data: {
          'name': name,
          'lastName': lastName,
          'age': age,
          'height': height,
          'weight': weight,
          'activityLevel': activityLevel,
          'goal': goal,
          'allergies': allergies,
          'likes': likes,
          'dislikes': dislikes,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print("Respuesta: ${response.data}");
      if (response.statusCode == 201) {
        final String userId = response.data['user']['id'].toString();
        print('🆔 Usuario creado con ID: $userId');

        // Opcional: guardarlo en almacenamiento local
        await LocalStorage.prefs.setString('userId', userId);

        return userId; // ✅ Devuelve el id
      } else {
        return null;
      }
    } on DioException catch (e) {
      print("Error: ${e}");
      return null;
    }
  }

  Future<List<Map<String, dynamic>?>> generateRecommendations(String id) async {
    try {
      String token = LocalStorage.prefs.getString('token') ?? '';

      final response = await _dio.get(
        "/food/recommendations/$id",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print("Respuesta: ${response.data}");

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
          response.data['recommendations'],
        );
      } else {
        print("Error: código de estado ${response.statusCode}");
        return [];
      }
    } on DioException catch (e) {
      print(
        "Error al obtener recomendaciones: ${e.response?.data ?? e.message}",
      );
      return [];
    } catch (e) {
      print("Error inesperado: $e");
      return [];
    }
  }

  Future<bool> createPlan(String userId, int calories) async {
    try {
      String token = LocalStorage.prefs.getString('token') ?? '';

      final response = await _dio.put(
        "/user/goalCalories/$userId",
        data: {'goalCalories': calories},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print("Respuesta: ${response.data}");

      if (response.statusCode == 200) {
        print('Plan creado con éxito');
        return true;
      } else {
        print("Error: código de estado ${response.statusCode}");
        return false;
      }
    } on DioException catch (e) {
      print("Error al crear plan: ${e.response?.data ?? e.message}");
      return false;
    } catch (e) {
      print("Error inesperado: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> getFoodHistory(String userId) async {
    try {
      String token = LocalStorage.prefs.getString('token') ?? '';

      final response = await _dio.get(
        "/food/history/$userId",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print("Respuesta: ${response.data}");

      if (response.statusCode == 200) {
        return response.data;
      } else {
        print("Error: código de estado ${response.statusCode}");
        return {};
      }
    } on DioException catch (e) {
      print(
        "Error al obtener historial de comidas: ${e.response?.data ?? e.message}",
      );
      return {};
    } catch (e) {
      print("Error inesperado: $e");
      return {};
    }
  }
}
