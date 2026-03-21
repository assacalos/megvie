class AnnonceComment {
  final int id;
  final String contenu;
  final DateTime createdAt;
  final Map<String, dynamic>? user;

  AnnonceComment({
    required this.id,
    required this.contenu,
    required this.createdAt,
    this.user,
  });

  factory AnnonceComment.fromJson(Map<String, dynamic> json) {
    return AnnonceComment(
      id: json['id'],
      contenu: json['contenu'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      user: json['user'] != null ? Map<String, dynamic>.from(json['user']) : null,
    );
  }
}

class Annonce {
  final int id;
  final String titre;
  final String contenu;
  final String type;
  final DateTime datePublication;
  final DateTime? dateFinAffichage;
  final bool isPinned;
  final Map<String, dynamic>? createdBy;
  final int likesCount;
  final int commentsCount;
  final int partagesCount;
  final bool userHasLiked;
  final bool userHasShared;
  final List<AnnonceComment>? comments;

  Annonce({
    required this.id,
    required this.titre,
    required this.contenu,
    this.type = 'annonce',
    required this.datePublication,
    this.dateFinAffichage,
    this.isPinned = false,
    this.createdBy,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.partagesCount = 0,
    this.userHasLiked = false,
    this.userHasShared = false,
    this.comments,
  });

  factory Annonce.fromJson(Map<String, dynamic> json) {
    List<AnnonceComment>? commentsList;
    if (json['comments'] is List) {
      commentsList = (json['comments'] as List)
          .map((e) => AnnonceComment.fromJson(e as Map<String, dynamic>))
          .toList();
    }
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
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      partagesCount: json['partages_count'] ?? 0,
      userHasLiked: json['user_has_liked'] == true,
      userHasShared: json['user_has_shared'] == true,
      comments: commentsList,
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

  Annonce copyWith({
    int? likesCount,
    int? commentsCount,
    int? partagesCount,
    bool? userHasLiked,
    bool? userHasShared,
    List<AnnonceComment>? comments,
  }) {
    return Annonce(
      id: id,
      titre: titre,
      contenu: contenu,
      type: type,
      datePublication: datePublication,
      dateFinAffichage: dateFinAffichage,
      isPinned: isPinned,
      createdBy: createdBy,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      partagesCount: partagesCount ?? this.partagesCount,
      userHasLiked: userHasLiked ?? this.userHasLiked,
      userHasShared: userHasShared ?? this.userHasShared,
      comments: comments ?? this.comments,
    );
  }
}
