class RequetePriere {
  final int id;
  final int? fideleId;
  final String contenu;
  final String statut;
  final bool isAnonyme;
  final DateTime? createdAt;
  final Map<String, dynamic>? fidele;

  RequetePriere({
    required this.id,
    this.fideleId,
    required this.contenu,
    this.statut = 'nouvelle',
    this.isAnonyme = false,
    this.createdAt,
    this.fidele,
  });

  factory RequetePriere.fromJson(Map<String, dynamic> json) {
    return RequetePriere(
      id: json['id'],
      fideleId: json['fidele_id'],
      contenu: json['contenu'],
      statut: json['statut'] ?? 'nouvelle',
      isAnonyme: json['is_anonyme'] == true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      fidele: json['fidele'],
    );
  }

  Map<String, dynamic> toJson() => {
        'contenu': contenu,
        'is_anonyme': isAnonyme,
      };

  String get statutLabel {
    switch (statut) {
      case 'en_priere': return 'En prière';
      case 'traitee': return 'Traitée';
      default: return 'Nouvelle';
    }
  }
}
