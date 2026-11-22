class Categoria {
  const Categoria({this.id, required this.nome});

  final int? id;
  final String nome;

  factory Categoria.fromMap(Map<String, Object?> map) =>
      Categoria(id: map['id'] as int, nome: map['name'] as String);

  Map<String, Object?> toMap() => {'name': nome};
}
