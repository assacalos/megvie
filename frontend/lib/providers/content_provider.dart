import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/annonce.dart';
import '../models/document.dart';
import '../models/operation_financiere.dart';
import '../models/rendez_vous.dart';
import '../models/mediatheque_item.dart';
import '../models/requete_priere.dart';
import '../models/temoignage.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

/// Provider central pour Annonces, Documents, Finances, RDV, Médiathèque, Prière, Témoignages.
class ContentProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<Annonce> _annonces = [];
  Annonce? _selectedAnnonce;
  List<Document> _documents = [];
  List<OperationFinanciere> _operations = [];
  Map<String, dynamic>? _statsFinance;
  List<RendezVous> _rendezVous = [];
  RendezVous? _selectedRendezVous;
  List<MediathequeItem> _mediatheque = [];
  MediathequeItem? _selectedMediathequeItem;
  List<RequetePriere> _requetesPriere = [];
  List<Temoignage> _temoignages = [];
  bool _isLoading = false;
  String? _error;

  List<Annonce> get annonces => _annonces;
  Annonce? get selectedAnnonce => _selectedAnnonce;
  List<Document> get documents => _documents;
  List<OperationFinanciere> get operations => _operations;
  Map<String, dynamic>? get statsFinance => _statsFinance;
  List<RendezVous> get rendezVous => _rendezVous;
  RendezVous? get selectedRendezVous => _selectedRendezVous;
  List<MediathequeItem> get mediatheque => _mediatheque;
  MediathequeItem? get selectedMediathequeItem => _selectedMediathequeItem;
  List<RequetePriere> get requetesPriere => _requetesPriere;
  List<Temoignage> get temoignages => _temoignages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get documentBaseUrl => '${AppConstants.getBaseUrl()}/storage/';

  // --- Annonces ---
  Future<void> fetchAnnonces({String? type}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final q = type != null ? {'type': type} : null;
      final r = await _api.get('/api/annonces', queryParameters: q);
      if (r.statusCode == 200) {
        final data = r.data['data'] ?? r.data;
        _annonces = ((data is List ? data : data['data'] ?? []) as List)
            .map((e) => Annonce.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Annonce?> fetchAnnonce(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final r = await _api.get('/api/annonces/$id');
      if (r.statusCode == 200) {
        _selectedAnnonce = Annonce.fromJson(r.data);
        _isLoading = false;
        notifyListeners();
        return _selectedAnnonce;
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<bool> createAnnonce(Annonce a) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final r = await _api.post('/api/annonces', data: a.toJson());
      if (r.statusCode == 200 || r.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateAnnonce(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final r = await _api.put('/api/annonces/$id', data: data);
      if (r.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteAnnonce(int id) async {
    try {
      await _api.delete('/api/annonces/$id');
      _annonces.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // --- Documents ---
  Future<void> fetchDocuments({String? type}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final q = type != null ? {'type': type} : null;
      final r = await _api.get('/api/documents', queryParameters: q);
      if (r.statusCode == 200) {
        final data = r.data['data'] ?? r.data;
        _documents = ((data is List ? data : data['data'] ?? []) as List)
            .map((e) => Document.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> uploadDocument(String titre, String? description, String type, String filePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final formData = FormData.fromMap({
        'titre': titre,
        'description': description ?? '',
        'type': type,
        'fichier': await MultipartFile.fromFile(filePath),
      });
      final r = await _api.postFormData('/api/documents', formData);
      if (r.statusCode == 200 || r.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteDocument(int id) async {
    try {
      await _api.delete('/api/documents/$id');
      _documents.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // --- Operations financières ---
  Future<void> fetchOperations({int? fideleId, String? type, String? dateDebut, String? dateFin}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final q = <String, dynamic>{};
      if (fideleId != null) q['fidele_id'] = fideleId;
      if (type != null) q['type'] = type;
      if (dateDebut != null) q['date_debut'] = dateDebut;
      if (dateFin != null) q['date_fin'] = dateFin;
      final r = await _api.get('/api/operations-financieres', queryParameters: q.isEmpty ? null : q);
      if (r.statusCode == 200) {
        final data = r.data['data'] ?? r.data;
        _operations = ((data is List ? data : data['data'] ?? []) as List)
            .map((e) => OperationFinanciere.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchStatsFinance({int? fideleId, String? dateDebut, String? dateFin}) async {
    try {
      final q = <String, dynamic>{};
      if (fideleId != null) q['fidele_id'] = fideleId;
      if (dateDebut != null) q['date_debut'] = dateDebut;
      if (dateFin != null) q['date_fin'] = dateFin;
      final r = await _api.get('/api/operations-financieres/stats', queryParameters: q.isEmpty ? null : q);
      if (r.statusCode == 200) _statsFinance = Map<String, dynamic>.from(r.data);
    } catch (_) {}
    notifyListeners();
  }

  Future<bool> createOperation(OperationFinanciere op) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final r = await _api.post('/api/operations-financieres', data: op.toJson());
      if (r.statusCode == 200 || r.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteOperation(int id) async {
    try {
      await _api.delete('/api/operations-financieres/$id');
      _operations.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // --- Rendez-vous ---
  Future<void> fetchRendezVous({int? fideleId, String? statut}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final q = <String, dynamic>{};
      if (fideleId != null) q['fidele_id'] = fideleId;
      if (statut != null) q['statut'] = statut;
      final r = await _api.get('/api/rendez-vous', queryParameters: q.isEmpty ? null : q);
      if (r.statusCode == 200) {
        final data = r.data['data'] ?? r.data;
        _rendezVous = ((data is List ? data : data['data'] ?? []) as List)
            .map((e) => RendezVous.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<RendezVous?> fetchRendezVousDetail(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final r = await _api.get('/api/rendez-vous/$id');
      if (r.statusCode == 200) {
        _selectedRendezVous = RendezVous.fromJson(r.data);
        _isLoading = false;
        notifyListeners();
        return _selectedRendezVous;
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<bool> createRendezVous(RendezVous rdv) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final r = await _api.post('/api/rendez-vous', data: rdv.toJson());
      if (r.statusCode == 200 || r.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateRendezVous(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final r = await _api.put('/api/rendez-vous/$id', data: data);
      if (r.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteRendezVous(int id) async {
    try {
      await _api.delete('/api/rendez-vous/$id');
      _rendezVous.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // --- Médiathèque ---
  Future<void> fetchMediatheque({String? type}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final q = type != null ? {'type': type} : null;
      final r = await _api.get('/api/mediatheque', queryParameters: q);
      if (r.statusCode == 200) {
        final data = r.data['data'] ?? r.data;
        _mediatheque = ((data is List ? data : data['data'] ?? []) as List)
            .map((e) => MediathequeItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<MediathequeItem?> fetchMediathequeItem(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final r = await _api.get('/api/mediatheque/$id');
      if (r.statusCode == 200) {
        _selectedMediathequeItem = MediathequeItem.fromJson(r.data);
        _isLoading = false;
        notifyListeners();
        return _selectedMediathequeItem;
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<bool> createMediathequeItem(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final r = await _api.post('/api/mediatheque', data: data);
      if (r.statusCode == 200 || r.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateMediathequeItem(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final r = await _api.put('/api/mediatheque/$id', data: data);
      if (r.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteMediathequeItem(int id) async {
    try {
      await _api.delete('/api/mediatheque/$id');
      _mediatheque.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // --- Requêtes de prière ---
  Future<void> fetchRequetesPriere({String? statut}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final q = statut != null ? {'statut': statut} : null;
      final r = await _api.get('/api/requetes-priere', queryParameters: q);
      if (r.statusCode == 200) {
        final data = r.data['data'] ?? r.data;
        _requetesPriere = ((data is List ? data : data['data'] ?? []) as List)
            .map((e) => RequetePriere.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createRequetePriere(RequetePriere req) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final r = await _api.post('/api/requetes-priere', data: req.toJson());
      if (r.statusCode == 200 || r.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateStatutRequetePriere(int id, String statut) async {
    try {
      await _api.put('/api/requetes-priere/$id', data: {'statut': statut});
      await fetchRequetesPriere();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // --- Témoignages ---
  Future<void> fetchTemoignages({String? statut}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final q = statut != null ? {'statut': statut} : null;
      final r = await _api.get('/api/temoignages', queryParameters: q);
      if (r.statusCode == 200) {
        final data = r.data['data'] ?? r.data;
        _temoignages = ((data is List ? data : data['data'] ?? []) as List)
            .map((e) => Temoignage.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createTemoignage(Temoignage t) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final r = await _api.post('/api/temoignages', data: t.toJson());
      if (r.statusCode == 200 || r.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateTemoignage(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final r = await _api.put('/api/temoignages/$id', data: data);
      if (r.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteTemoignage(int id) async {
    try {
      await _api.delete('/api/temoignages/$id');
      _temoignages.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
