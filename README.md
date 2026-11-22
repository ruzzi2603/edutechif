# EduTechIF Mobile

Aplicativo Flutter para organizar cursos online do IFSULDEMINAS. Os dados são
persistidos localmente em SQLite e cada usuário visualiza apenas os próprios
cursos.

## Funcionalidades

- Cadastro e login com e-mail e senha; senhas armazenadas com PBKDF2-HMAC-SHA256,
  salt aleatório e 120.000 iterações.
- Dashboard com resumo dos cursos cadastrados.
- CRUD de cursos, com nome, descrição, instrutor, carga horária, link e
  categoria.
- CRUD de categorias. Ao excluir uma categoria, os cursos associados são
  mantidos e ficam sem categoria.
- Busca por nome do curso, categoria ou instrutor.
- Logout e validação dos formulários.

## Tecnologias

- Flutter e Dart.
- SQLite pelo pacote `sqflite`; o banco é criado automaticamente na primeira
  execução.
- `path` para formar o caminho do banco e `crypto` para HMAC/SHA-256.

## Executar

Instale o Flutter e configure um dispositivo Android ou emulador com o Android
SDK. Na pasta `edutechif`, execute:

```bash
flutter pub get
flutter run
```

O banco `edutechif.db` é armazenado no diretório de dados privado do aplicativo.
Desinstalar o aplicativo remove esse banco.

## Verificar e gerar APK

```bash
flutter analyze
flutter test
flutter build apk --release
```

O APK gerado fica em
`build/app/outputs/flutter-apk/app-release.apk`.

## Estrutura

```text
lib/
  database/database_helper.dart
  models/
  screens/
  services/
  widgets/
  main.dart
test/
```

O banco usa chaves estrangeiras, e-mail único e categoria única por usuário
(sem distinção entre maiúsculas e minúsculas), restrição de carga horária
positiva e exclusão em cascata dos cursos e categorias quando uma conta é
removida.

> A autenticação local protege as senhas armazenadas, mas não substitui um
> serviço de identidade remoto nem deve ser tratada como autenticação de
> produção.
