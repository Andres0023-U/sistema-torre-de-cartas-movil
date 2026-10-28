import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torre_de_cartas_movil/core/di/injection_container.dart' as di;
import 'package:torre_de_cartas_movil/main.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    GoogleFonts.config.allowRuntimeFetching = false;
    di.initDependencies();
  });

  testWidgets('Verificar que la aplicación inicie', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
