import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5F3EC),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: Color(0xFF2E8065),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'EduTechIF',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.06),
                    Container(
                      width: size.width < 430 ? 220 : 260,
                      height: size.width < 430 ? 220 : 260,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F4EE),
                        borderRadius: BorderRadius.circular(42),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.auto_stories_rounded,
                          size: 108,
                          color: Color(0xFF2E8065),
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    Text(
                      'Cresça com novos conhecimentos',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800, height: 1.15),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Organize seus cursos online em um só lugar e acompanhe sua jornada de aprendizagem.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF718078),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: onRegister,
                        child: const Text('Criar minha conta'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: onLogin,
                        child: const Text('Já tenho uma conta'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'IFSULDEMINAS  •  Aprender sempre',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF89968F),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
