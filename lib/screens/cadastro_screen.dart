import 'package:flutter/material.dart';

import '../models/usuario.dart';
import 'login_screen.dart';

class CadastroScreen extends StatelessWidget {
  const CadastroScreen({
    super.key,
    required this.onAuthenticated,
    required this.onSwitchToLogin,
  });

  final ValueChanged<Usuario> onAuthenticated;
  final VoidCallback onSwitchToLogin;

  @override
  Widget build(BuildContext context) => AuthFormScreen(
    isRegister: true,
    onAuthenticated: onAuthenticated,
    onSwitchMode: onSwitchToLogin,
    onBackToHome: onSwitchToLogin,
  );
}
