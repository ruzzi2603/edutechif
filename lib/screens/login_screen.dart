import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/usuario_service.dart';
import '../widgets/app_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.onAuthenticated,
    required this.onSwitchToRegister,
    required this.onBackToHome,
  });

  final ValueChanged<Usuario> onAuthenticated;
  final VoidCallback onSwitchToRegister;
  final VoidCallback onBackToHome;

  @override
  Widget build(BuildContext context) => AuthFormScreen(
    onAuthenticated: onAuthenticated,
    onSwitchMode: onSwitchToRegister,
    onBackToHome: onBackToHome,
  );
}

class AuthFormScreen extends StatefulWidget {
  const AuthFormScreen({
    super.key,
    required this.onAuthenticated,
    required this.onSwitchMode,
    required this.onBackToHome,
    this.isRegister = false,
  });

  final ValueChanged<Usuario> onAuthenticated;
  final VoidCallback onSwitchMode;
  final VoidCallback onBackToHome;
  final bool isRegister;

  @override
  State<AuthFormScreen> createState() => _AuthFormScreenState();
}

class _AuthFormScreenState extends State<AuthFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _service = UsuarioService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final usuario = widget.isRegister
          ? await _service.cadastrar(
              nome: _nameController.text,
              email: _emailController.text,
              senha: _passwordController.text,
            )
          : await _service.autenticar(
              email: _emailController.text,
              senha: _passwordController.text,
            );
      if (mounted) widget.onAuthenticated(usuario);
    } on UsuarioServiceException catch (error) {
      _showMessage(error.message);
    } on Exception {
      _showMessage('Não foi possível acessar sua conta. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isRegister = widget.isRegister;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: widget.isRegister
              ? widget.onSwitchMode
              : widget.onBackToHome,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F3EC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Color(0xFF2E8065),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isRegister ? 'Crie sua conta' : 'Bem-vindo de volta',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isRegister
                          ? 'Cadastre-se para organizar seus cursos.'
                          : 'Entre para continuar sua jornada de aprendizagem.',
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: const Color(0xFF718078)),
                    ),
                    const SizedBox(height: 28),
                    if (isRegister) ...[
                      AppTextField(
                        controller: _nameController,
                        label: 'Nome completo',
                        icon: Icons.person_outline,
                        validator: (value) =>
                            value == null || value.trim().length < 2
                            ? 'Informe seu nome.'
                            : null,
                      ),
                      const SizedBox(height: 14),
                    ],
                    AppTextField(
                      controller: _emailController,
                      label: 'E-mail',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(email)
                            ? null
                            : 'Informe um e-mail válido.';
                      },
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _passwordController,
                      label: 'Senha',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) {
                        final password = value ?? '';
                        if (isRegister && password.length < 8) {
                          return 'Use pelo menos 8 caracteres.';
                        }
                        return password.isEmpty ? 'Informe sua senha.' : null;
                      },
                    ),
                    if (isRegister) ...[
                      const SizedBox(height: 9),
                      Text(
                        'Sua senha é armazenada como hash e não em texto aberto.',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: const Color(0xFF718078)),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(isRegister ? 'Criar conta' : 'Entrar'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: widget.onSwitchMode,
                      child: Text(
                        isRegister
                            ? 'Já tem uma conta? Entrar'
                            : 'Ainda não tem conta? Cadastre-se',
                      ),
                    ),
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
