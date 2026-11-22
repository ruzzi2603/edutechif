import '../database/database_helper.dart';
import '../models/categoria.dart';
import '../models/curso.dart';

class CursoService {
  CursoService({DatabaseHelper? database})
    : _database = database ?? DatabaseHelper.instance;

  final DatabaseHelper _database;

  Future<List<Curso>> listar(int usuarioId) => _database.getCourses(usuarioId);

  Future<void> salvar(Curso curso) async {
    if (curso.id == null) {
      await _database.insertCourse(curso);
    } else {
      final rows = await _database.updateCourse(curso);
      if (rows == 0) {
        throw StateError('O curso não foi encontrado para atualização.');
      }
    }
  }

  Future<void> excluir(int cursoId, int usuarioId) async {
    final rows = await _database.deleteCourse(cursoId, usuarioId);
    if (rows == 0) {
      throw StateError('O curso não foi encontrado para exclusão.');
    }
  }

  Future<List<Categoria>> listarCategorias(int usuarioId) =>
      _database.getCategories(usuarioId);
}
