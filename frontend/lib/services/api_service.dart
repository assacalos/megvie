import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;

  void init(String baseUrl) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint('=== REQUÊTE HTTP ===');
          debugPrint('URL: ${options.baseUrl}${options.path}');
          debugPrint('Méthode: ${options.method}');
          debugPrint('Headers: ${options.headers}');
          debugPrint('Data: ${options.data}');
          debugPrint('Query Parameters: ${options.queryParameters}');

          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint('Token ajouté aux headers');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('=== RÉPONSE HTTP ===');
          debugPrint('Status Code: ${response.statusCode}');
          debugPrint('Headers: ${response.headers}');
          debugPrint('Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('=== ERREUR HTTP ===');
          debugPrint('Type: ${error.type}');
          debugPrint('Message: ${error.message}');
          debugPrint('Status Code: ${error.response?.statusCode}');
          debugPrint('Response Data: ${error.response?.data}');
          debugPrint('Request Path: ${error.requestOptions.path}');
          debugPrint('Request Data: ${error.requestOptions.data}');

          if (error.response != null) {
            debugPrint('Response Headers: ${error.response!.headers}');
          }

          if (error.response?.statusCode == 401) {
            debugPrint('Erreur 401: Non autorisé');
            // Gérer la déconnexion
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> postFile(
    String path,
    String filePath,
    String fieldName, {
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      Map<String, dynamic> formDataMap = {
        fieldName: await MultipartFile.fromFile(filePath),
      };

      if (additionalData != null) {
        formDataMap.addAll(additionalData);
      }

      FormData formData = FormData.fromMap(formDataMap);
      return await _dio.post(path, data: formData);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> postFormData(String path, FormData formData) async {
    try {
      return await _dio.post(path, data: formData);
    } catch (e) {
      rethrow;
    }
  }

  /// Envoi de SMS en masse aux fidèles sélectionnés.
  /// [fideleIds] : liste des IDs des fidèles, [message] : texte du SMS.
  Future<Response> sendBulkSms(List<int> fideleIds, String message) async {
    return post(
      '/api/send-bulk-sms',
      data: {
        'fidele_ids': fideleIds,
        'message': message,
      },
    );
  }
}
