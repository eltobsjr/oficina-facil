import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/app.dart';

void main() {
  testWidgets('abre a tela inicial com o nome do app', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: OficinaFacilApp()));
    await tester.pumpAndSettle();

    expect(find.text('OficinaFácil'), findsOneWidget);
  });
}
