import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/app.dart';
import 'package:oficina_facil/core/network/api_client.dart';

Widget _app({bool servidorOk = true}) {
  return ProviderScope(
    overrides: [apiSaudeProvider.overrideWith((ref) async => servidorOk)],
    child: const OficinaFacilApp(),
  );
}

void main() {
  testWidgets('abre a tela inicial com o nome do app', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('OficinaFácil'), findsOneWidget);
    expect(find.text('Aguardando aprovação'), findsOneWidget);
  });

  testWidgets('mostra o servidor conectado quando /health responde', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Servidor conectado'), findsOneWidget);
  });

  testWidgets('mostra o servidor indisponível quando /health falha', (
    tester,
  ) async {
    await tester.pumpWidget(_app(servidorOk: false));
    await tester.pumpAndSettle();

    expect(find.text('Servidor indisponível'), findsOneWidget);
  });

  testWidgets('abre em português do Brasil', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    final contexto = tester.element(find.byType(Scaffold));
    expect(Localizations.localeOf(contexto), const Locale('pt', 'BR'));
    expect(
      MaterialLocalizations.of(contexto).okButtonLabel,
      'OK',
      reason: 'carregou os textos do Material em pt-BR',
    );
    expect(MaterialLocalizations.of(contexto).cancelButtonLabel, 'Cancelar');
  });
}
