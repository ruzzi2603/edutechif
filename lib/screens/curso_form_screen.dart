import 'package:flutter/material.dart';

import '../models/categoria.dart';
import '../models/curso.dart';
import '../services/curso_service.dart';
import '../widgets/app_text_field.dart';

class CursoFormScreen extends StatefulWidget {
  const CursoFormScreen({super.key, required this.usuarioId, this.curso});

  final int usuarioId;
  final Curso? curso;

  @override
  State<CursoFormScreen> createState() => _CursoFormScreenState();
}

class _CursoFormScreenState extends State<CursoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructorController = TextEditingController();
  final _hoursController = TextEditingController();
  final _urlController = TextEditingController();
  final _service = CursoService();
  late final Future<List<Categoria>> _categoriesFuture;
  int? _categoryId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final curso = widget.curso;
    _nameController.text = curso?.nome ?? '';
    _descriptionController.text = curso?.descricao ?? '';
    _instructorController.text = curso?.instrutor ?? '';
    _hoursController.text = curso?.cargaHoraria.toString() ?? '';
    _urlController.text = curso?.url ?? '';
    _categoryId = curso?.categoriaId;
    _categoriesFuture = _service.listarCategorias(widget.usuarioId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructorController.dispose();
    _hoursController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final existing = widget.curso;
    final course = Curso(
      id: existing?.id,
      nome: _nameController.text.trim(),
      descricao: _descriptionController.text.trim(),
      instrutor: _instructorController.text.trim(),
      cargaHoraria: int.parse(_hoursController.text.trim()),
      url: _urlController.text.trim(),
      categoriaId: _categoryId,
      usuarioId: widget.usuarioId,
      criadoEm: existing?.criadoEm ?? DateTime.now().toUtc().toIso8601String(),
    );
    try {
      await _service.salvar(course);
      if (mounted) Navigator.of(context).pop(true);
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível salvar o curso: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _required(String? value, String field) =>
      value == null || value.trim().isEmpty ? 'Informe $field.' : null;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.curso == null ? 'Novo curso' : 'Editar curso'),
    ),
    body: SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              'Informações do curso',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Os dados cadastrados ficam salvos neste dispositivo.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: const Color(0xFF718078)),
            ),
            const SizedBox(height: 22),
            AppTextField(
              controller: _nameController,
              label: 'Nome do curso',
              icon: Icons.menu_book_outlined,
              validator: (value) => _required(value, 'o nome'),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _descriptionController,
              label: 'Descrição',
              icon: Icons.notes_rounded,
              maxLines: 4,
              validator: (value) => _required(value, 'a descrição'),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _instructorController,
              label: 'Instrutor ou instituição',
              icon: Icons.person_outline,
              validator: (value) => _required(value, 'o instrutor'),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _hoursController,
              label: 'Carga horária (horas)',
              icon: Icons.schedule,
              keyboardType: TextInputType.number,
              validator: (value) {
                final hours = int.tryParse(value?.trim() ?? '');
                return hours == null || hours <= 0
                    ? 'Informe uma carga horária maior que zero.'
                    : null;
              },
            ),
            const SizedBox(height: 14),
            FutureBuilder<List<Categoria>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    'Não foi possível carregar as categorias: ${snapshot.error}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const LinearProgressIndicator();
                }
                final categories = snapshot.data!;
                final selectedId =
                    categories.any((category) => category.id == _categoryId)
                    ? _categoryId
                    : null;
                return DropdownButtonFormField<int?>(
                  initialValue: selectedId,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Sem categoria'),
                    ),
                    ...categories.map(
                      (category) => DropdownMenuItem<int?>(
                        value: category.id,
                        child: Text(category.nome),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _categoryId = value),
                );
              },
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _urlController,
              label: 'Link do curso (opcional)',
              icon: Icons.link_rounded,
              keyboardType: TextInputType.url,
              validator: (value) {
                final url = value?.trim() ?? '';
                final uri = Uri.tryParse(url);
                if (url.isNotEmpty &&
                    (uri == null ||
                        !uri.hasScheme ||
                        !uri.hasAuthority ||
                        !{'http', 'https'}.contains(uri.scheme))) {
                  return 'Informe um link iniciado por http:// ou https://.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(
                  widget.curso == null
                      ? 'Cadastrar curso'
                      : 'Salvar alterações',
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
