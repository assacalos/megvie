import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/fidele.dart';
import '../services/api_service.dart';

class FideleProvider with ChangeNotifier {
  List<Fidele> _fideles = [];
  Fidele? _selectedFidele;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _stats;

  List<Fidele> get fideles => _fideles;
  Fidele? get selectedFidele => _selectedFidele;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get stats => _stats;

  Future<void> fetchFideles({
    String? search,
    String? trancheAge,
    String? dateDebut,
    String? dateFin,
    int? corpsMetierId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final apiService = ApiService();
      final queryParams = <String, dynamic>{};

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (trancheAge != null && trancheAge != 'tous')
        queryParams['tranche_age'] = trancheAge;
      if (dateDebut != null) queryParams['date_debut'] = dateDebut;
      if (dateFin != null) queryParams['date_fin'] = dateFin;
      if (corpsMetierId != null) queryParams['corps_metier_id'] = corpsMetierId;

      final response = await apiService.get(
        '/api/fideles',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        _fideles = (data as List).map((json) => Fidele.fromJson(json)).toList();
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur lors du chargement: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFidele(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final apiService = ApiService();
      final response = await apiService.get('/api/fideles/$id');

      if (response.statusCode == 200) {
        _selectedFidele = Fidele.fromJson(response.data);
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur lors du chargement: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createFidele(Fidele fidele, {String? photoPath}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final apiService = ApiService();
      final data = fidele.toJson();

      Response response;
      if (photoPath != null) {
        // Envoyer le fichier avec les données
        final formData = FormData.fromMap({
          'photo': await MultipartFile.fromFile(photoPath),
          ...data,
        });
        response = await apiService.postFormData('/api/fideles', formData);
      } else {
        response = await apiService.post('/api/fideles', data: data);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Erreur lors de la création: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateFidele(
    int id,
    Map<String, dynamic> data, {
    String? photoPath,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final apiService = ApiService();

      Response response;
      if (photoPath != null) {
        final formData = FormData.fromMap({
          'photo': await MultipartFile.fromFile(photoPath),
          ...data,
        });
        response = await apiService.postFormData('/api/fideles/$id', formData);
      } else {
        response = await apiService.put('/api/fideles/$id', data: data);
      }

      if (response.statusCode == 200) {
        await fetchFidele(id);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchStats() async {
    try {
      final apiService = ApiService();
      final response = await apiService.get('/api/fideles/stats');

      if (response.statusCode == 200) {
        _stats = response.data;
        notifyListeners();
      }
    } catch (e) {
      // Ignorer les erreurs de stats
    }
  }

  Future<void> deleteFidele(int id) async {
    try {
      final apiService = ApiService();
      await apiService.delete('/api/fideles/$id');
      _fideles.removeWhere((f) => f.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la suppression: ${e.toString()}';
      notifyListeners();
    }
  }
}
