import 'package:dio/dio.dart';
import 'package:nutri_kids_movil/services/local_storage.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.18.41:3000/api', // Cambia esto por tu URL base
      connectTimeout: Duration(milliseconds: 5000),
      receiveTimeout: Duration(milliseconds: 3000),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static bool _interceptorAdded = false;

  static Dio get dio {
    // Interceptor para adjuntar el token si existe
    if (!_interceptorAdded) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = LocalStorage.prefs.getString("token");
            if (token != null) {
              options.headers["Authorization"] = "Bearer $token";
            }
            return handler.next(options);
          },
          onError: (DioException e, handler) {
            // Aquí puedes manejar errores globales (ej: token expirado)
            return handler.next(e);
          },
        ),
      );
      _interceptorAdded = true;
    }
    return _dio;
  }
}