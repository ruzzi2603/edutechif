import 'package:flutter/material.dart';

import '../models/categoria.dart';
import '../services/categoria_service.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key, required this.usuarioId});

  final int usuarioId;

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  final _service = CategoriaService();
  late Future<List<Categoria>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _categoriesFuture = _service.listar(widget.usuarioId);
    if (mounted) setState(() {});
  }

  Future<void> _editCategory([Categoria? category]) async {
    final controller = TextEditingController(text: category?.nome ?? '');
    final formKey = GlobalKey<FormState>();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(category == null ? 'Nova categoria' : 'Editar categoria'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLength: 40,
            decoration: const InputDecoration(
              labelText: 'Nome da categoria',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Informe um nome.'
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null) return;
    try {
      await _service.salvar(
        Categoria(id: category?.id, nome: name),
        widget.usuarioId,
      );
      if (mounted) _reload();
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível salvar a categoria: $error'),
          ),
        );
      }
    }
  }

  Future<void> _deleteCategory(Categoria category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir categoria?'),
        content: Text(
          '“${category.nome}” será removida. Os cursos vinculados ficarão sem categoria.',
        ),
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
      await _service.excluir(category.id!, widget.usuarioId);
      if (mounted) _reload();
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível excluir a categoria: $error'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _editCategory,
      icon: const Icon(Icons.add),
      label: const Text('Nova categoria'),
    ),
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categorias',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Agrupe seus cursos por assunto.',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: const Color(0xFF718078)),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Categoria>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 44),
                          const SizedBox(height: 12),
                          Text(
                            'Não foi possível carregar as categorias: ${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: _reload,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final categories = snapshot.data!;
                if (categories.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.category_outlined,
                            size: 48,
                            color: Color(0xFF8A9991),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Nenhuma categoria cadastrada.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _editCategory,
                            child: const Text('Criar categoria'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Card(
                      margin: EdgeInsets.zero,
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE9EFEC)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F4EE),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.sell_outlined,
                            color: Color(0xFF2E8065),
                          ),
                        ),
                        title: Text(
                          category.nome,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        trailing: PopupMenuButton<String>(
                          tooltip: 'Ações da categoria',
                          onSelected: (action) {
                            if (action == 'edit') {
                              _editCategory(category);
                            } else {
                              _deleteCategory(category);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Editar')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Excluir'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
