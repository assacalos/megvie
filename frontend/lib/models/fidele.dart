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
  final String? appartientFamille;
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
      souhaiteAppartenir: json['souhaite_appartenir'] ?? false,
      dateArrivee:
          json['date_arrivee'] != null
              ? DateTime.parse(json['date_arrivee'])
              : null,
      appartientFamille: json['appartient_famille'],
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
      'formation': formation,
      'annee_experience': anneeExperience,
      'corps_metier_id': corpsMetierId,
    };
  }

  String get fullName => '$nom $prenoms';
}
