class Annonce {
  final int id;
  final String titre;
  final String contenu;
  final String type;
  final DateTime datePublication;
  final DateTime? dateFinAffichage;
  final bool isPinned;
  final Map<String, dynamic>? createdBy;

  Annonce({
    required this.id,
    required this.titre,
    required this.contenu,
    this.type = 'annonce',
    required this.datePublication,
    this.dateFinAffichage,
    this.isPinned = false,
    this.createdBy,
  });

  factory Annonce.fromJson(Map<String, dynamic> json) {
    return Annonce(
      id: json['id'],
      titre: json['titre'],
      contenu: json['contenu'],
      type: json['type'] ?? 'annonce',
      datePublication: DateTime.parse(json['date_publication']),
      dateFinAffichage: json['date_fin_affichage'] != null
          ? DateTime.parse(json['date_fin_affichage'])
          : null,
      isPinned: json['is_pinned'] == true,
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() => {
        'titre': titre,
        'contenu': contenu,
        'type': type,
        'date_publication': datePublication.toIso8601String().split('T')[0],
        'date_fin_affichage': dateFinAffichage?.toIso8601String().split('T')[0],
        'is_pinned': isPinned,
      };
}
