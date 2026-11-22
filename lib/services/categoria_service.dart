import '../database/database_helper.dart';
import '../models/categoria.dart';

class CategoriaService {
  CategoriaService({DatabaseHelper? database})
    : _database = database ?? DatabaseHelper.instance;

  final DatabaseHelper _database;

  Future<List<Categoria>> listar(int usuarioId) =>
      _database.getCategories(usuarioId);

  Future<void> salvar(Categoria categoria, int usuarioId) async {
    final nome = categoria.nome.trim();
    if (nome.isEmpty) {
      throw const CategoriaServiceException(
        'Informe um nome para a categoria.',
      );
    }
    if (categoria.id == null) {
      await _database.insertCategory(Categoria(nome: nome), usuarioId);
    } else {
      final rows = await _database.updateCategory(
        Categoria(id: categoria.id, nome: nome),
        usuarioId,
      );
      if (rows == 0) {
        throw const CategoriaServiceException(
          'A categoria não foi encontrada.',
        );
      }
    }
  }

  Future<void> excluir(int id, int usuarioId) async {
    final rows = await _database.deleteCategory(id, usuarioId);
    if (rows == 0) {
      throw const CategoriaServiceException('A categoria não foi encontrada.');
    }
  }
}

class CategoriaServiceException implements Exception {
  const CategoriaServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
