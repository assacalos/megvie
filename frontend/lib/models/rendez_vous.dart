class RendezVous {
  final int id;
  final int fideleId;
  final String type;
  final String sujet;
  final DateTime? dateSouhaitee;
  final String? heureSouhaitee;
  final String statut;
  final String? noteFidele;
  final String? notePasteur;
  final int? assigneAId;
  final DateTime? dateEffectif;
  final Map<String, dynamic>? fidele;
  final Map<String, dynamic>? assigneA;

  RendezVous({
    required this.id,
    required this.fideleId,
    this.type = 'pastoral',
    required this.sujet,
    this.dateSouhaitee,
    this.heureSouhaitee,
    this.statut = 'en_attente',
    this.noteFidele,
    this.notePasteur,
    this.assigneAId,
    this.dateEffectif,
    this.fidele,
    this.assigneA,
  });

  factory RendezVous.fromJson(Map<String, dynamic> json) {
    return RendezVous(
      id: json['id'],
      fideleId: json['fidele_id'],
      type: json['type'] ?? 'pastoral',
      sujet: json['sujet'],
      dateSouhaitee: json['date_souhaitee'] != null ? DateTime.parse(json['date_souhaitee']) : null,
      heureSouhaitee: json['heure_souhaitee']?.toString(),
      statut: json['statut'] ?? 'en_attente',
      noteFidele: json['note_fidele'],
      notePasteur: json['note_pasteur'],
      assigneAId: json['assigne_a'],
      dateEffectif: json['date_effectif'] != null ? DateTime.tryParse(json['date_effectif'].toString()) : null,
      fidele: json['fidele'],
      assigneA: json['assigne_a'] is Map ? json['assigne_a'] : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'fidele_id': fideleId,
        'type': type,
        'sujet': sujet,
        'date_souhaitee': dateSouhaitee?.toIso8601String().split('T')[0],
        'heure_souhaitee': heureSouhaitee,
        'note_fidele': noteFidele,
      };

  String get typeLabel => type == 'pastoral' ? 'Pastoral' : type == 'priere' ? 'Prière' : 'Autre';
  String get statutLabel {
    switch (statut) {
      case 'confirme': return 'Confirmé';
      case 'annule': return 'Annulé';
      case 'effectue': return 'Effectué';
      default: return 'En attente';
    }
  }
}
