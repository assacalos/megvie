import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _user != null && _token != null;

  /// Restaure la session depuis SharedPreferences (au démarrage de l'app).
  /// Garde l'utilisateur connecté tant qu'il ne s'est pas déconnecté.
  Future<void> init() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userJson = prefs.getString('user');

    if (token != null && token.isNotEmpty && userJson != null && userJson.isNotEmpty) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        _user = User.fromJson(userMap);
        _token = token;
      } catch (e) {
        debugPrint('AuthProvider.init: erreur restauration user: $e');
        await prefs.remove('auth_token');
        await prefs.remove('user');
      }
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('=== DÉBUT LOGIN ===');
      debugPrint('Email: $email');

      final apiService = ApiService();
      final requestData = {
        'email': email,
        'password': password,
      };

      debugPrint('Données de la requête: $requestData');

      final response = await apiService.post(
        '/api/login',
        data: requestData,
      );

      debugPrint('Réponse reçue:');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        debugPrint('Login réussi');
        _token = response.data['token'];
        debugPrint('Token extrait: ${_token?.substring(0, 20)}...');

        _user = User.fromJson(response.data['user']);
        debugPrint('User créé: ${_user?.email}');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user', jsonEncode(_user!.toJson()));
        debugPrint('Session sauvegardée (reste connecté après fermeture de l\'app)');

        _isLoading = false;
        notifyListeners();
        debugPrint('=== FIN LOGIN (SUCCÈS) ===');
        return true;
      } else {
        debugPrint('Status code non 200: ${response.statusCode}');
        _error = 'Identifiants incorrects';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('=== ERREUR LOGIN ===');
      debugPrint('Type d\'erreur: ${e.runtimeType}');
      debugPrint('Message: ${e.toString()}');
      debugPrint('Stack trace: $stackTrace');

      if (e is DioException) {
        debugPrint('DioException détectée');
        debugPrint('Type: ${e.type}');
        debugPrint('Message: ${e.message}');
        debugPrint('Response: ${e.response?.data}');
        debugPrint('Status Code: ${e.response?.statusCode}');

        _error = 'Erreur de connexion: ${e.message}';
        if (e.response?.data != null) {
          final errorData = e.response!.data;
          if (errorData is Map && errorData.containsKey('message')) {
            _error = errorData['message'];
          } else if (errorData is Map && errorData.containsKey('error')) {
            _error = errorData['error'];
          }
        }
      } else {
        _error = 'Erreur de connexion: ${e.toString()}';
      }

      _isLoading = false;
      notifyListeners();
      debugPrint('=== FIN LOGIN (ERREUR) ===');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final apiService = ApiService();
      await apiService.post('/api/logout');
    } catch (e) {
      // Ignorer les erreurs de déconnexion
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user');

    _user = null;
    _token = null;
    _error = null;
    notifyListeners();
  }
}
