import 'package:flutter/material.dart';

import '../models/curso.dart';
import '../services/curso_service.dart';
import 'curso_form_screen.dart';

class DetalhesCursoScreen extends StatefulWidget {
  const DetalhesCursoScreen({
    super.key,
    required this.curso,
    required this.usuarioId,
  });

  final Curso curso;
  final int usuarioId;

  @override
  State<DetalhesCursoScreen> createState() => _DetalhesCursoScreenState();
}

class _DetalhesCursoScreenState extends State<DetalhesCursoScreen> {
  late Curso _curso;
  final _service = CursoService();

  @override
  void initState() {
    super.initState();
    _curso = widget.curso;
  }

  Future<void> _edit() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            CursoFormScreen(usuarioId: widget.usuarioId, curso: _curso),
      ),
    );
    if (changed == true && mounted) Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir curso?'),
        content: Text('“${_curso.nome}” será removido permanentemente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _service.excluir(_curso.id!, widget.usuarioId);
      if (mounted) Navigator.of(context).pop(true);
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível excluir o curso: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Detalhes do curso'),
      actions: [
        IconButton(
          tooltip: 'Editar curso',
          onPressed: _edit,
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          tooltip: 'Excluir curso',
          onPressed: _delete,
          icon: const Icon(Icons.delete_outline),
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Container(
          height: 190,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E8065), Color(0xFF58B58A)],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Icon(
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 74,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _curso.categoriaNome ?? 'Curso online',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: const Color(0xFF2E8065),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _curso.nome,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _InfoPill(icon: Icons.person_outline, label: _curso.instrutor),
            const SizedBox(width: 10),
            _InfoPill(
              icon: Icons.schedule,
              label: '${_curso.cargaHoraria} horas',
            ),
          ],
        ),
        const SizedBox(height: 26),
        Text(
          'Sobre o curso',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Text(
          _curso.descricao,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: const Color(0xFF64726A), height: 1.55),
        ),
        if (_curso.url.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text(
            'Link do curso',
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          SelectableText(
            _curso.url,
            style: const TextStyle(color: Color(0xFF2E8065)),
          ),
        ],
        const SizedBox(height: 28),
        OutlinedButton.icon(
          onPressed: _edit,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Editar informações'),
        ),
      ],
    ),
  );
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9EFEC)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: const Color(0xFF2E8065)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}
