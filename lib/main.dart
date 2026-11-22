import 'package:flutter/material.dart';

import 'models/usuario.dart';
import 'screens/cadastro_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EduTechIfApp());
}

class EduTechIfApp extends StatefulWidget {
  const EduTechIfApp({super.key});

  @override
  State<EduTechIfApp> createState() => _EduTechIfAppState();
}

class _EduTechIfAppState extends State<EduTechIfApp> {
  Usuario? _usuario;
  bool _mostrarAutenticacao = false;
  bool _modoCadastro = false;

  void _abrirAutenticacao({bool cadastro = false}) {
    setState(() {
      _mostrarAutenticacao = true;
      _modoCadastro = cadastro;
    });
  }

  void _encerrarSessao() {
    setState(() {
      _usuario = null;
      _mostrarAutenticacao = false;
      _modoCadastro = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const verde = Color(0xFF2E8065);
    return MaterialApp(
      title: 'EduTechIF',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: verde,
          primary: verde,
          surface: const Color(0xFFF7F9F8),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F9F8),
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE6ECE9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: verde, width: 1.5),
          ),
        ),
      ),
      home: _usuario != null
          ? DashboardScreen(usuario: _usuario!, onLogout: _encerrarSessao)
          : _mostrarAutenticacao
          ? _modoCadastro
                ? CadastroScreen(
                    onAuthenticated: (usuario) =>
                        setState(() => _usuario = usuario),
                    onSwitchToLogin: () =>
                        setState(() => _modoCadastro = false),
                  )
                : LoginScreen(
                    onAuthenticated: (usuario) =>
                        setState(() => _usuario = usuario),
                    onSwitchToRegister: () =>
                        setState(() => _modoCadastro = true),
                    onBackToHome: () =>
                        setState(() => _mostrarAutenticacao = false),
                  )
          : HomeScreen(
              onLogin: () => _abrirAutenticacao(),
              onRegister: () => _abrirAutenticacao(cadastro: true),
            ),
    );
  }
}
