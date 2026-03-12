class Temoignage {
  final int id;
  final int? fideleId;
  final String titre;
  final String contenu;
  final String statut;
  final Map<String, dynamic>? fidele;
  final Map<String, dynamic>? approuvePar;
  final DateTime? dateApprobation;

  Temoignage({
    required this.id,
    this.fideleId,
    required this.titre,
    required this.contenu,
    this.statut = 'en_attente',
    this.fidele,
    this.approuvePar,
    this.dateApprobation,
  });

  factory Temoignage.fromJson(Map<String, dynamic> json) {
    return Temoignage(
      id: json['id'],
      fideleId: json['fidele_id'],
      titre: json['titre'],
      contenu: json['contenu'],
      statut: json['statut'] ?? 'en_attente',
      fidele: json['fidele'],
      approuvePar: json['approuve_par'],
      dateApprobation: json['date_approbation'] != null ? DateTime.tryParse(json['date_approbation'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'titre': titre,
        'contenu': contenu,
      };

  String get statutLabel {
    switch (statut) {
      case 'approuve': return 'Approuvé';
      case 'rejete': return 'Rejeté';
      default: return 'En attente';
    }
  }
}
