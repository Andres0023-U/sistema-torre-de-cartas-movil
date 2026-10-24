import 'package:flutter_test/flutter_test.dart';
import 'package:torre_de_cartas_movil/core/di/injection_container.dart' as di;
import 'package:torre_de_cartas_movil/main.dart';

void main() {
  setUp(() {
    di.initDependencies();
  });

  testWidgets('Verificar que la aplicación inicie', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
