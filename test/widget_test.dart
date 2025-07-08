import 'package:flutter_test/flutter_test.dart';
import 'package:blocify/main.dart';

void main() {
  testWidgets('Blocify app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BlocifyApp());

    expect(find.text('Blocify'), findsOneWidget);
    expect(find.text('Usuario'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
