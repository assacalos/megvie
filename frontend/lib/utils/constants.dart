import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConstants {
  static SharedPreferences? _prefs;

  /// true si l'app tourne sur un émulateur (détecté au init)
  static bool _isEmulator = false;

  // Initialiser SharedPreferences et détecter l'émulateur (à appeler au démarrage)
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _isEmulator = await _checkIsEmulator();
  }

  static Future<bool> _checkIsEmulator() async {
    if (kIsWeb) return false;
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        return !android.isPhysicalDevice;
      }
      if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        return !ios.isPhysicalDevice;
      }
    } catch (_) {}
    return false;
  }

  // URLs
  static const String _defaultBaseUrl = 'http://10.0.2.2:8000';
  static const String _productionBaseUrl = 'https://megvie.smil-app.com';
  static const String apiPrefix = '/api';

  /// Récupère l'URL de base de l'API
  static String getBaseUrl() {
    // Vérifier si une URL personnalisée est stockée (priorité la plus haute)
    final customUrl = _prefs?.getString('api_base_url');
    if (customUrl != null && customUrl.isNotEmpty) {
      return customUrl;
    }

    // Vérifier si on force l'URL de production via variable d'environnement
    const bool forceProduction = bool.fromEnvironment(
      'FORCE_PRODUCTION_URL',
      defaultValue: false,
    );
    if (forceProduction) {
      return _productionBaseUrl;
    }

    // Sur émulateur : utiliser l'URL locale (évite "Failed host lookup" sur megvie.smil-app.com)
    if (_isEmulator) {
      if (kIsWeb) return 'http://localhost:8000';
      if (Platform.isAndroid) return _defaultBaseUrl;
      if (Platform.isIOS) return 'http://localhost:8000';
    }

    // En mode debug sur Android : toujours utiliser l'URL locale (émulateur ou device)
    // Évite "Failed host lookup: megvie.smil-app.com" sur l'émulateur.
    // Pour tester la prod sur un appareil Android en debug : flutter run --dart-define=FORCE_PRODUCTION_URL=true
    if (kDebugMode && !kIsWeb) {
      try {
        if (Platform.isAndroid) return _defaultBaseUrl;
      } catch (_) {}
    }

    // Vérifier si on veut utiliser l'URL locale via variable d'environnement
    const bool useLocalUrl = bool.fromEnvironment(
      'USE_LOCAL_URL',
      defaultValue: false,
    );
    if (kDebugMode && useLocalUrl) {
      if (kIsWeb) return 'http://localhost:8000';
      if (!kIsWeb) {
        try {
          if (Platform.isAndroid) return _defaultBaseUrl;
        } catch (e) {}
      }
      return 'http://localhost:8000';
    }

    // Par défaut : URL de production (release ou téléphone en prod)
    return _productionBaseUrl;
  }

  /// Retourne l'URL complète de l'API
  static String get apiUrl => "${getBaseUrl()}$apiPrefix";

  /// Retourne l'URL de production
  static String get productionUrl => _productionBaseUrl;

  /// Retourne l'URL locale (pour développement)
  static String get localUrl => _defaultBaseUrl;

  /// Indique si l'app tourne sur un émulateur
  static bool get isEmulator => _isEmulator;

  /// Vérifie quelle URL est actuellement utilisée
  static String getCurrentUrlInfo() {
    final currentUrl = getBaseUrl();
    if (currentUrl == _productionBaseUrl) {
      return 'Production: $_productionBaseUrl';
    } else if (currentUrl == _defaultBaseUrl ||
        currentUrl.contains('localhost') ||
        currentUrl.contains('10.0.2.2')) {
      return _isEmulator
          ? 'Émulateur (locale): $currentUrl'
          : 'Locale: $currentUrl';
    } else {
      return 'Personnalisée: $currentUrl';
    }
  }

  /// Définit l'URL de base de l'API
  static Future<void> setBaseUrl(String url) async {
    await _prefs?.setString('api_base_url', url);
  }

  /// Réinitialise l'URL à la valeur par défaut
  static Future<void> resetBaseUrl() async {
    await _prefs?.remove('api_base_url');
  }

  // Tranches d'âge
  static const List<Map<String, String>> tranchesAge = [
    {'value': '5-11', 'label': 'De 5 - 11 ans'},
    {'value': '12-17', 'label': 'De 12 - 17 ans'},
    {'value': '18-25', 'label': 'De 18 - 25 ans'},
    {'value': '26-35', 'label': 'De 26 - 35 ans'},
    {'value': '36-45', 'label': 'De 36 - 45 ans'},
    {'value': '46+', 'label': 'Plus de 46 ans'},
  ];

  // Comment connu
  static const List<String> commentConnuOptions = [
    'Evangelisation',
    'Media',
    'Internet',
    'Invitation',
    'De passage',
  ];

  // But de visite
  static const List<String> butVisiteOptions = [
    'Nouveau dans le quartier',
    'Être membre',
    'De passage',
    'Invitation',
    'Besoin de prière',
    'Rencontrer un pasteur',
  ];

  // Statuts de suivi
  static const List<Map<String, String>> statutsSuivi = [
    {'value': 'pas_interesse', 'label': 'Pas intéressé'},
    {'value': 'injoignable', 'label': 'Injoignable'},
    {'value': 'confirme', 'label': 'Confirmé'},
    {'value': 'visite_prochaine_fois', 'label': 'Visite une prochaine fois'},
  ];

  // Types d'actions
  static const List<Map<String, String>> typesActions = [
    {'value': 'action_sociale', 'label': 'Action sociale'},
    {'value': 'attribution_marche', 'label': 'Attribution de marché'},
    {'value': 'accompagnement_projet', 'label': 'Accompagnement projet'},
  ];
}
