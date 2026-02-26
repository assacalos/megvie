class Fidele {
  final int id;
  final String nom;
  final String prenoms;
  final String? trancheAge;
  final String? lieuResidence;
  final String? commentConnu;
  final String? butVisite;
  final String? quiInvite;
  final String? frequenteEglise;
  final bool souhaiteAppartenir;
  final DateTime? dateArrivee;
  final bool? appartientFamille;
  final String statut;
  final String? profession;
  final String? photo;
  final String? facebook;
  final String? contacts;
  final String? whatsapp;
  final String? instagram;
  final String? email;
  final int? parrainId;
  final int? pasteurId;
  final int? chefDiscId;
  final int? familleId;

  /// Mois sélectionné pour "Famille" (Janvier à Décembre)
  final String? familleMois;
  final String? formation;
  final int? anneeExperience;
  final int? corpsMetierId;
  final Map<String, dynamic>? parrain;
  final Map<String, dynamic>? pasteur;
  final Map<String, dynamic>? chefDisc;
  final Map<String, dynamic>? famille;
  final Map<String, dynamic>? corpsMetier;
  final List<dynamic>? suivis;
  final List<dynamic>? actions;
  final bool? baptiseEau;
  final bool? baptiseSaintEsprit;
  final bool? cureDAme;
  final bool? delivrance;
  final bool? mariage;

  /// Date de dernière mise à jour des champs pasteur (baptêmes, cure, délivrance, mariage)
  final DateTime? dateMiseAJourPasteur;
  /// Date de dernière mise à jour parrain / pasteur / famille
  final DateTime? dateMiseAJourParrainage;
  /// Date de dernière mise à jour formation / année exp. / corps métier
  final DateTime? dateMiseAJourSocioPro;
  /// Date de toute dernière mise à jour
  final DateTime? dateDerniereMiseAJour;

  Fidele({
    required this.id,
    required this.nom,
    required this.prenoms,
    this.trancheAge,
    this.lieuResidence,
    this.commentConnu,
    this.butVisite,
    this.quiInvite,
    this.frequenteEglise,
    this.souhaiteAppartenir = false,
    this.dateArrivee,
    this.appartientFamille,
    this.statut = 'nouvel_ame',
    this.profession,
    this.photo,
    this.facebook,
    this.contacts,
    this.whatsapp,
    this.instagram,
    this.email,
    this.parrainId,
    this.pasteurId,
    this.chefDiscId,
    this.familleId,
    this.familleMois,
    this.formation,
    this.anneeExperience,
    this.corpsMetierId,
    this.parrain,
    this.pasteur,
    this.chefDisc,
    this.famille,
    this.corpsMetier,
    this.suivis,
    this.actions,
    this.baptiseEau,
    this.baptiseSaintEsprit,
    this.cureDAme,
    this.delivrance,
    this.mariage,
    this.dateMiseAJourPasteur,
    this.dateMiseAJourParrainage,
    this.dateMiseAJourSocioPro,
    this.dateDerniereMiseAJour,
  });

  factory Fidele.fromJson(Map<String, dynamic> json) {
    return Fidele(
      id: json['id'],
      nom: json['nom'],
      prenoms: json['prenoms'],
      trancheAge: json['tranche_age'],
      lieuResidence: json['lieu_residence'],
      commentConnu: json['comment_connu'],
      butVisite: json['but_visite'],
      quiInvite: json['qui_invite'],
      frequenteEglise: json['frequente_eglise'],
      souhaiteAppartenir: _parseBool(json['souhaite_appartenir']) ?? false,
      dateArrivee: json['date_arrivee'] != null
          ? DateTime.parse(json['date_arrivee'])
          : null,
      appartientFamille: _parseBool(json['appartient_famille']),
      statut: json['statut'] ?? 'nouvel_ame',
      profession: json['profession'],
      photo: json['photo'],
      facebook: json['facebook'],
      contacts: json['contacts'],
      whatsapp: json['whatsapp'],
      instagram: json['instagram'],
      email: json['email'],
      parrainId: json['parrain_id'],
      pasteurId: json['pasteur_id'],
      chefDiscId: json['chef_disc_id'],
      familleId: json['famille_id'],
      familleMois: json['famille_mois'],
      formation: json['formation'],
      anneeExperience: json['annee_experience'],
      corpsMetierId: json['corps_metier_id'],
      parrain: json['parrain'],
      pasteur: json['pasteur'],
      chefDisc: json['chef_disc'],
      famille: json['famille'],
      corpsMetier: json['corps_metier'],
      suivis: json['suivis'],
      actions: json['actions'],
      baptiseEau: _parseBool(json['baptise_eau']),
      baptiseSaintEsprit: _parseBool(json['baptise_saint_esprit']),
      cureDAme: _parseBool(json['cure_d_ame']),
      delivrance: _parseBool(json['delivrance']),
      mariage: _parseBool(json['mariage']),
      dateMiseAJourPasteur: json['date_mise_a_jour_pasteur'] != null
          ? DateTime.tryParse(json['date_mise_a_jour_pasteur'].toString())
          : null,
      dateMiseAJourParrainage: json['date_mise_a_jour_parrainage'] != null
          ? DateTime.tryParse(json['date_mise_a_jour_parrainage'].toString())
          : null,
      dateMiseAJourSocioPro: json['date_mise_a_jour_socio_pro'] != null
          ? DateTime.tryParse(json['date_mise_a_jour_socio_pro'].toString())
          : null,
      dateDerniereMiseAJour: json['date_derniere_mise_a_jour'] != null
          ? DateTime.tryParse(json['date_derniere_mise_a_jour'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenoms': prenoms,
      'tranche_age': trancheAge,
      'lieu_residence': lieuResidence,
      'comment_connu': commentConnu,
      'but_visite': butVisite,
      'qui_invite': quiInvite,
      'frequente_eglise': frequenteEglise,
      'souhaite_appartenir': souhaiteAppartenir,
      'date_arrivee': dateArrivee?.toIso8601String().split('T')[0],
      'appartient_famille': appartientFamille,
      'statut': statut,
      'profession': profession,
      'photo': photo,
      'facebook': facebook,
      'contacts': contacts,
      'whatsapp': whatsapp,
      'instagram': instagram,
      'email': email,
      'parrain_id': parrainId,
      'pasteur_id': pasteurId,
      'chef_disc_id': chefDiscId,
      'famille_id': familleId,
      'famille_mois': familleMois,
      'formation': formation,
      'annee_experience': anneeExperience,
      'corps_metier_id': corpsMetierId,
      'baptise_eau': baptiseEau,
      'baptise_saint_esprit': baptiseSaintEsprit,
      'cure_d_ame': cureDAme,
      'delivrance': delivrance,
      'mariage': mariage,
    };
  }

  String get fullName => '$nom $prenoms';

  // Méthode helper pour parser les booléens depuis int ou bool
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return null;
  }
}
