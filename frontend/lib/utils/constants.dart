class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:8000';
  static const String apiPrefix = '/api';

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
