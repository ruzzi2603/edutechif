class Usuario {
  const Usuario({this.id, required this.nome, required this.email});

  final int? id;
  final String nome;
  final String email;

  factory Usuario.fromMap(Map<String, Object?> map) => Usuario(
    id: map['id'] as int,
    nome: map['name'] as String,
    email: map['email'] as String,
  );

  Map<String, Object?> toMap({
    required String passwordHash,
    required String salt,
  }) => {
    'name': nome,
    'email': email,
    'password_hash': passwordHash,
    'salt': salt,
  };
}
