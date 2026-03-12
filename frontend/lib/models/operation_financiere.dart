class OperationFinanciere {
  final int id;
  final int fideleId;
  final String type;
  final double montant;
  final String devise;
  final DateTime dateOperation;
  final String modePaiement;
  final String? reference;
  final String? note;
  final Map<String, dynamic>? fidele;
  final Map<String, dynamic>? enregistrePar;

  OperationFinanciere({
    required this.id,
    required this.fideleId,
    required this.type,
    required this.montant,
    this.devise = 'XOF',
    required this.dateOperation,
    this.modePaiement = 'especes',
    this.reference,
    this.note,
    this.fidele,
    this.enregistrePar,
  });

  factory OperationFinanciere.fromJson(Map<String, dynamic> json) {
    return OperationFinanciere(
      id: json['id'],
      fideleId: json['fidele_id'],
      type: json['type'],
      montant: (json['montant'] is num) ? (json['montant'] as num).toDouble() : double.tryParse(json['montant'].toString()) ?? 0,
      devise: json['devise'] ?? 'XOF',
      dateOperation: DateTime.parse(json['date_operation']),
      modePaiement: json['mode_paiement'] ?? 'especes',
      reference: json['reference'],
      note: json['note'],
      fidele: json['fidele'],
      enregistrePar: json['enregistre_par'],
    );
  }

  Map<String, dynamic> toJson() => {
        'fidele_id': fideleId,
        'type': type,
        'montant': montant,
        'devise': devise,
        'date_operation': dateOperation.toIso8601String().split('T')[0],
        'mode_paiement': modePaiement,
        'reference': reference,
        'note': note,
      };

  String get typeLabel => type == 'dime' ? 'Dîme' : type == 'offrande' ? 'Offrande' : 'Don';
}
