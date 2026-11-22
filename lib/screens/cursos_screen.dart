import 'package:flutter/material.dart';

import '../models/curso.dart';
import '../services/curso_service.dart';
import '../widgets/curso_card.dart';
import 'curso_form_screen.dart';
import 'detalhes_curso_screen.dart';

class CursosScreen extends StatefulWidget {
  const CursosScreen({
    super.key,
    required this.usuarioId,
    required this.onCoursesChanged,
  });

  final int usuarioId;
  final VoidCallback onCoursesChanged;

  @override
  State<CursosScreen> createState() => _CursosScreenState();
}

class _CursosScreenState extends State<CursosScreen> {
  final _service = CursoService();
  final _searchController = TextEditingController();
  late Future<List<Curso>> _coursesFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _coursesFuture = _service.listar(widget.usuarioId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() => _coursesFuture = _service.listar(widget.usuarioId));
  }

  Future<void> _openCourse(Curso course) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            DetalhesCursoScreen(curso: course, usuarioId: widget.usuarioId),
      ),
    );
    if (changed == true && mounted) {
      _reload();
      widget.onCoursesChanged();
    }
  }

  Future<void> _addCourse() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CursoFormScreen(usuarioId: widget.usuarioId),
      ),
    );
    if (saved == true && mounted) {
      _reload();
      widget.onCoursesChanged();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _addCourse,
      icon: const Icon(Icons.add),
      label: const Text('Novo curso'),
    ),
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meus cursos',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Consulte e organize seus cursos online.',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: const Color(0xFF718078)),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _searchController,
                  onChanged: (value) =>
                      setState(() => _query = value.trim().toLowerCase()),
                  decoration: const InputDecoration(
                    hintText: 'Buscar curso ou categoria',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Curso>>(
              future: _coursesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _MessageState(
                    icon: Icons.error_outline,
                    message:
                        'Não foi possível carregar os cursos: ${snapshot.error}',
                    actionLabel: 'Tentar novamente',
                    onAction: _reload,
                  );
                }
                final courses = snapshot.data!
                    .where(
                      (course) =>
                          course.nome.toLowerCase().contains(_query) ||
                          (course.categoriaNome ?? '').toLowerCase().contains(
                            _query,
                          ) ||
                          course.instrutor.toLowerCase().contains(_query),
                    )
                    .toList();
                if (courses.isEmpty) {
                  final isEmpty = snapshot.data!.isEmpty;
                  return _MessageState(
                    icon: isEmpty
                        ? Icons.menu_book_outlined
                        : Icons.search_off_rounded,
                    message: isEmpty
                        ? 'Você ainda não cadastrou cursos.'
                        : 'Nenhum curso encontrado para esta busca.',
                    actionLabel: isEmpty ? 'Cadastrar primeiro curso' : null,
                    onAction: isEmpty ? _addCourse : null,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: courses.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) => CursoCard(
                    curso: courses[index],
                    onTap: () => _openCourse(courses[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: const Color(0xFF8A9991)),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    ),
  );
}
