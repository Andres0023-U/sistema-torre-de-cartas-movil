import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torre_de_cartas_movil/core/di/injection_container.dart' as di;
import 'package:torre_de_cartas_movil/main.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    di.initDependencies();
  });

  testWidgets('Verificar que la aplicación inicie', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
