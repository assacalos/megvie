class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final int? fideleId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.fideleId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'admin',
      fideleId: json['fidele_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      if (fideleId != null) 'fidele_id': fideleId,
    };
  }

  bool get isFidele => role == 'fidele';
}
