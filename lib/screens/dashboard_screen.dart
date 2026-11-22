import 'package:flutter/material.dart';

import '../models/curso.dart';
import '../models/usuario.dart';
import '../services/curso_service.dart';
import '../widgets/curso_card.dart';
import 'categorias_screen.dart';
import 'cursos_screen.dart';
import 'detalhes_curso_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.usuario,
    required this.onLogout,
  });

  final Usuario usuario;
  final VoidCallback onLogout;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  int _refreshVersion = 0;

  void _coursesChanged() => setState(() => _refreshVersion++);

  @override
  Widget build(BuildContext context) {
    final titles = ['Início', 'Meus cursos', 'Categorias'];
    final pages = [
      _DashboardHome(
        key: ValueKey(_refreshVersion),
        usuario: widget.usuario,
        onBrowseCourses: () => setState(() => _selectedIndex = 1),
      ),
      CursosScreen(
        usuarioId: widget.usuario.id!,
        onCoursesChanged: _coursesChanged,
      ),
      CategoriasScreen(usuarioId: widget.usuario.id!),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Conta',
            onSelected: (value) {
              if (value == 'logout') widget.onLogout();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 10),
                    Text('Encerrar sessão'),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: const Color(0xFFE5F3EC),
                child: Text(
                  widget.usuario.nome.trim().characters.first.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF2E8065),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Cursos',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category_rounded),
            label: 'Categorias',
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatefulWidget {
  const _DashboardHome({
    super.key,
    required this.usuario,
    required this.onBrowseCourses,
  });

  final Usuario usuario;
  final VoidCallback onBrowseCourses;

  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome> {
  final _service = CursoService();
  late Future<List<Curso>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture = _service.listar(widget.usuario.id!);
  }

  Future<void> _openCourse(Curso course) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            DetalhesCursoScreen(curso: course, usuarioId: widget.usuario.id!),
      ),
    );
    if (mounted) {
      setState(() => _coursesFuture = _service.listar(widget.usuario.id!));
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Curso>>(
    future: _coursesFuture,
    builder: (context, snapshot) {
      final courses = snapshot.data ?? const <Curso>[];
      final recentCourses = courses.take(3).toList();
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF28785E), Color(0xFF47A77C)],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, ${widget.usuario.nome.split(' ').first}!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Que tal aprender algo novo hoje?',
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      snapshot.hasError
                          ? 'Cursos indisponíveis'
                          : '${courses.length} ${courses.length == 1 ? 'curso cadastrado' : 'cursos cadastrados'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Continue organizando',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              TextButton(
                onPressed: widget.onBrowseCourses,
                child: const Text('Ver todos'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (snapshot.connectionState != ConnectionState.done)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (snapshot.hasError)
            _HomeNotice(
              icon: Icons.error_outline,
              message: 'Não foi possível carregar os cursos.',
              action: TextButton(
                onPressed: () => setState(
                  () => _coursesFuture = _service.listar(widget.usuario.id!),
                ),
                child: const Text('Tentar novamente'),
              ),
            )
          else if (recentCourses.isEmpty)
            _HomeNotice(
              icon: Icons.menu_book_outlined,
              message: 'Cadastre seu primeiro curso para começar a organizar seus estudos.',
              action: FilledButton.tonal(
                onPressed: widget.onBrowseCourses,
                child: const Text('Explorar meus cursos'),
              ),
            )
          else
            ...recentCourses.map(
              (course) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CursoCard(
                  curso: course,
                  onTap: () => _openCourse(course),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            'Seus estudos, no seu ritmo',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE9EFEC)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFF2E8065),
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cadastre cursos de diferentes fontes e mantenha suas informações organizadas.',
                    style: TextStyle(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

class _HomeNotice extends StatelessWidget {
  const _HomeNotice({
    required this.icon,
    required this.message,
    required this.action,
  });

  final IconData icon;
  final String message;
  final Widget action;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE9EFEC)),
    ),
    child: Column(
      children: [
        Icon(icon, size: 38, color: const Color(0xFF7F9086)),
        const SizedBox(height: 10),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        action,
      ],
    ),
  );
}
