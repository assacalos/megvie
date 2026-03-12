class MediathequeItem {
  final int id;
  final String titre;
  final String type;
  final String urlOrPath;
  final String? description;
  final DateTime? datePublication;
  final int? dureeSecondes;
  final String? auteur;
  final String? serieOrCategorie;

  MediathequeItem({
    required this.id,
    required this.titre,
    required this.type,
    required this.urlOrPath,
    this.description,
    this.datePublication,
    this.dureeSecondes,
    this.auteur,
    this.serieOrCategorie,
  });

  factory MediathequeItem.fromJson(Map<String, dynamic> json) {
    return MediathequeItem(
      id: json['id'],
      titre: json['titre'],
      type: json['type'],
      urlOrPath: json['url_or_path'] ?? '',
      description: json['description'],
      datePublication: json['date_publication'] != null ? DateTime.tryParse(json['date_publication'].toString()) : null,
      dureeSecondes: json['duree_secondes'],
      auteur: json['auteur'],
      serieOrCategorie: json['serie_or_categorie'],
    );
  }

  String get typeLabel {
    switch (type) {
      case 'video': return 'Vidéo';
      case 'audio': return 'Audio';
      case 'note_predication': return 'Note de prédication';
      case 'ressource_biblique': return 'Ressource biblique';
      default: return type;
    }
  }

  String get dureeFormatee {
    if (dureeSecondes == null) return '';
    final m = dureeSecondes! ~/ 60;
    final s = dureeSecondes! % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
