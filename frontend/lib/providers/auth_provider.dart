import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userJson = prefs.getString('user');

    if (token != null && userJson != null) {
      _token = token;
      // TODO: Améliorer la sérialisation/désérialisation de l'utilisateur
      try {
        // Pour l'instant, on récupère juste le token
        // Vous pouvez utiliser jsonEncode/jsonDecode pour une meilleure gestion
        notifyListeners();
      } catch (e) {
        // En cas d'erreur, on nettoie
        await prefs.remove('auth_token');
        await prefs.remove('user');
      }
    }
  }

  Future<bool> login(
    String email,
    String password, {
    String? typeConnexion,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final apiService = ApiService();
      final response = await apiService.post(
        '/api/login',
        data: {
          'email': email,
          'password': password,
          if (typeConnexion != null) 'type_connexion': typeConnexion,
        },
      );

      if (response.statusCode == 200) {
        _token = response.data['token'];
        _user = User.fromJson(response.data['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        // TODO: Utiliser jsonEncode pour une meilleure sérialisation
        await prefs.setString('user', _user!.toJson().toString());

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Identifiants incorrects';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erreur de connexion: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
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
