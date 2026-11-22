class Curso {
  const Curso({
    this.id,
    required this.nome,
    required this.descricao,
    required this.instrutor,
    required this.cargaHoraria,
    this.url = '',
    this.categoriaId,
    this.categoriaNome,
    required this.usuarioId,
    required this.criadoEm,
  });

  final int? id;
  final String nome;
  final String descricao;
  final String instrutor;
  final int cargaHoraria;
  final String url;
  final int? categoriaId;
  final String? categoriaNome;
  final int usuarioId;
  final String criadoEm;

  factory Curso.fromMap(Map<String, Object?> map) => Curso(
    id: map['id'] as int,
    nome: map['name'] as String,
    descricao: map['description'] as String,
    instrutor: map['instructor'] as String,
    cargaHoraria: map['workload_hours'] as int,
    url: map['url'] as String? ?? '',
    categoriaId: map['category_id'] as int?,
    categoriaNome: map['category_name'] as String?,
    usuarioId: map['owner_id'] as int,
    criadoEm: map['created_at'] as String,
  );

  Map<String, Object?> toMap() => {
    'name': nome,
    'description': descricao,
    'instructor': instrutor,
    'workload_hours': cargaHoraria,
    'url': url,
    'category_id': categoriaId,
    'owner_id': usuarioId,
    'created_at': criadoEm,
  };
}
