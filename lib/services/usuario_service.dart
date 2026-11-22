import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/usuario.dart';

class UsuarioService {
  UsuarioService({DatabaseHelper? database})
    : _database = database ?? DatabaseHelper.instance;

  final DatabaseHelper _database;

  Future<Usuario> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (await _database.findUserIdByEmail(normalizedEmail) != null) {
      throw const UsuarioServiceException(
        'Este e-mail já está cadastrado. Faça login ou use outro e-mail.',
      );
    }

    final salt = _createSalt();
    final hash = await _hashPassword(senha, salt);
    final user = Usuario(nome: nome.trim(), email: normalizedEmail);
    final id = await _database.insertUser(
      user.toMap(passwordHash: hash, salt: salt)
        ..['created_at'] = DateTime.now().toUtc().toIso8601String(),
    );
    return Usuario(id: id, nome: user.nome, email: user.email);
  }

  Future<Usuario> autenticar({
    required String email,
    required String senha,
  }) async {
    final credentials = await _database.findUserCredentials(
      email.trim().toLowerCase(),
    );
    if (credentials == null) {
      throw const UsuarioServiceException('E-mail ou senha incorretos.');
    }

    final candidate = await _hashPassword(senha, credentials['salt'] as String);
    if (!_constantTimeEquals(
      candidate,
      credentials['password_hash'] as String,
    )) {
      throw const UsuarioServiceException('E-mail ou senha incorretos.');
    }
    return Usuario.fromMap(credentials);
  }

  String _createSalt() {
    final random = Random.secure();
    return List<int>.generate(
      16,
      (_) => random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<String> _hashPassword(String password, String salt) =>
      compute(_derivePbkdf2, {'password': password, 'salt': salt});

  bool _constantTimeEquals(String first, String second) {
    if (first.length != second.length) return false;
    var difference = 0;
    for (var index = 0; index < first.length; index++) {
      difference |= first.codeUnitAt(index) ^ second.codeUnitAt(index);
    }
    return difference == 0;
  }
}

String _derivePbkdf2(Map<String, String> input) {
  const iterations = 120000;
  const keyLength = 32;
  final password = utf8.encode(input['password']!);
  final salt = <int>[...utf8.encode(input['salt']!), 0, 0, 0, 1];
  final hmac = Hmac(sha256, password);
  var current = hmac.convert(salt).bytes;
  final derived = List<int>.from(current);
  for (var iteration = 1; iteration < iterations; iteration++) {
    current = hmac.convert(current).bytes;
    for (var index = 0; index < keyLength; index++) {
      derived[index] ^= current[index];
    }
  }
  return derived.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

class UsuarioServiceException implements Exception {
  const UsuarioServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
