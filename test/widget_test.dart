import 'package:edutechif/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe a tela inicial e permite abrir o cadastro', (
    tester,
  ) async {
    await tester.pumpWidget(const EduTechIfApp());

    expect(find.text('EduTechIF'), findsOneWidget);
    expect(find.text('Cresça com novos conhecimentos'), findsOneWidget);

    await tester.ensureVisible(find.text('Criar minha conta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Criar minha conta'));
    await tester.pumpAndSettle();

    expect(find.text('Crie sua conta'), findsOneWidget);
    expect(find.text('Nome completo'), findsOneWidget);
  });
}
