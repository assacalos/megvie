import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class ReferenceProvider with ChangeNotifier {
  List<Map<String, dynamic>> _parrains = [];
  List<Map<String, dynamic>> _pasteurs = [];
  List<Map<String, dynamic>> _chefDiscs = [];
  List<Map<String, dynamic>> _serviceSociaux = [];
  List<Map<String, dynamic>> _familles = [];
  List<Map<String, dynamic>> _corpsMetiers = [];
  List<Map<String, dynamic>> _travailleurs = [];
  List<Map<String, dynamic>> _users = [];

  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get parrains => _parrains;
  List<Map<String, dynamic>> get pasteurs => _pasteurs;
  List<Map<String, dynamic>> get chefDiscs => _chefDiscs;
  List<Map<String, dynamic>> get serviceSociaux => _serviceSociaux;
  List<Map<String, dynamic>> get familles => _familles;
  List<Map<String, dynamic>> get corpsMetiers => _corpsMetiers;
  List<Map<String, dynamic>> get travailleurs => _travailleurs;
  List<Map<String, dynamic>> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charge les parrains. Si [familleId] est fourni, ne retourne que les parrains de cette famille.
  Future<void> fetchParrains({int? familleId}) async {
    try {
      final apiService = ApiService();
      final queryParams = <String, dynamic>{'role': 'parrain'};
      if (familleId != null) queryParams['famille_id'] = familleId;
      final response =
          await apiService.get('/api/users', queryParameters: queryParams);

      if (response.statusCode == 200) {
        _parrains = List<Map<String, dynamic>>.from(response.data);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur lors du chargement des parrains: ${e.toString()}';
      debugPrint(_error);
    }
  }

  Future<void> fetchPasteurs() async {
    try {
      final apiService = ApiService();
      final response = await apiService
          .get('/api/users', queryParameters: {'role': 'pasteur'});

      if (response.statusCode == 200) {
        _pasteurs = List<Map<String, dynamic>>.from(response.data);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur lors du chargement des pasteurs: ${e.toString()}';
      debugPrint(_error);
    }
  }

  Future<void> fetchChefDiscs() async {
    try {
      final apiService = ApiService();
      final response = await apiService
          .get('/api/users', queryParameters: {'role': 'chef_disc'});

      if (response.statusCode == 200) {
        _chefDiscs = List<Map<String, dynamic>>.from(response.data);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur lors du chargement des chefs de disc: ${e.toString()}';
      debugPrint(_error);
    }
  }

  Future<void> fetchFamilles() async {
    try {
      final apiService = ApiService();
      final response = await apiService
          .get('/api/users', queryParameters: {'role': 'famille'});

      if (response.statusCode == 200) {
        _familles = List<Map<String, dynamic>>.from(response.data);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur lors du chargement des familles: ${e.toString()}';
      debugPrint(_error);
    }
  }

  Future<void> fetchCorpsMetiers() async {
    try {
      final apiService = ApiService();
      final response = await apiService
          .get('/api/users', queryParameters: {'role': 'corps_metier'});

      if (response.statusCode == 200) {
        _corpsMetiers = List<Map<String, dynamic>>.from(response.data);
        notifyListeners();
      }
    } catch (e) {
      _error =
          'Erreur lors du chargement des corps de métiers: ${e.toString()}';
      debugPrint(_error);
    }
  }

  Future<void> fetchUsers() async {
    try {
      final apiService = ApiService();
      final response = await apiService
          .get('/api/users', queryParameters: {'role': 'admin'});

      if (response.statusCode == 200) {
        _users = List<Map<String, dynamic>>.from(response.data);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur lors du chargement des utilisateurs: ${e.toString()}';
      debugPrint(_error);
    }
  }

  Future<void> fetchServiceSociaux() async {
    try {
      final apiService = ApiService();
      final response = await apiService
          .get('/api/users', queryParameters: {'role': 'service_social'});

      if (response.statusCode == 200) {
        _serviceSociaux = List<Map<String, dynamic>>.from(response.data);
        notifyListeners();
      }
    } catch (e) {
      _error =
          'Erreur lors du chargement des services sociaux: ${e.toString()}';
      debugPrint(_error);
    }
  }

  Future<void> fetchTravailleurs() async {
    try {
      final apiService = ApiService();
      final response = await apiService
          .get('/api/users', queryParameters: {'role': 'travailleur'});

      if (response.statusCode == 200) {
        _travailleurs = List<Map<String, dynamic>>.from(response.data);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur lors du chargement des travailleurs: ${e.toString()}';
      debugPrint(_error);
    }
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      fetchParrains(),
      fetchPasteurs(),
      fetchServiceSociaux(),
      fetchFamilles(),
      fetchTravailleurs(),
      fetchUsers(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  // Méthodes de création - Toutes utilisent /api/users avec le bon role
  Future<bool> _createUserWithRole(
      Map<String, dynamic> data, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final apiService = ApiService();
      // Ajouter le role aux données
      final userData = {...data, 'role': role};
      final response = await apiService.post('/api/users', data: userData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Recharger la liste correspondante
        switch (role) {
          case 'admin':
          case 'sous_admin':
            await fetchUsers();
            break;
          case 'pasteur':
            await fetchPasteurs();
            break;
          case 'famille':
            await fetchFamilles();
            break;
          case 'parrain':
            await fetchParrains();
            break;
          case 'service_social':
            await fetchServiceSociaux();
            break;
          case 'travailleur':
            await fetchTravailleurs();
            break;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erreur lors de la création: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createPasteur(Map<String, dynamic> data) async {
    return await _createUserWithRole(data, 'pasteur');
  }

  Future<bool> createFamille(Map<String, dynamic> data) async {
    return await _createUserWithRole(data, 'famille');
  }

  Future<bool> createParrain(Map<String, dynamic> data) async {
    return await _createUserWithRole(data, 'parrain');
  }

  Future<bool> createChefDisc(Map<String, dynamic> data) async {
    return await _createUserWithRole(data, 'chef_disc');
  }

  Future<bool> createCorpsMetier(Map<String, dynamic> data) async {
    return await _createUserWithRole(data, 'corps_metier');
  }

  Future<bool> createUser(Map<String, dynamic> data) async {
    // Le role est déjà dans data (admin, sous_admin, etc.)
    return await _createUserWithRole(data, data['role'] ?? 'admin');
  }

  Future<bool> createServiceSocial(Map<String, dynamic> data) async {
    return await _createUserWithRole(data, 'service_social');
  }

  Future<bool> createTravailleur(Map<String, dynamic> data) async {
    return await _createUserWithRole(data, 'travailleur');
  }
}
