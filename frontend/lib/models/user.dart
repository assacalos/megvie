class User {
  final int id;
  final String name;
  final String email;
  final String? typeConnexion;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.typeConnexion,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      typeConnexion: json['type_connexion'],
      role: json['role'] ?? 'admin',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'type_connexion': typeConnexion,
      'role': role,
    };
  }
}
