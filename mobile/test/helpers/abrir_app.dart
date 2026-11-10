import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/app.dart';
import 'package:oficina_facil/core/network/api_client.dart';
import 'package:oficina_facil/features/autenticacao/presentation/providers/sessao_provider.dart';

import 'autenticacao_falsa.dart';

/// Tela larga usada pelos testes de fluxo: o menu vira barra lateral e cabe a lista inteira.
const telaLarga = Size(900, 1400);

/// Define o tamanho da tela do teste e o desfaz ao fim dele.
void usarTela(WidgetTester tester, Size tamanho) {
  tester.view.physicalSize = tamanho;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void usarTelaLarga(WidgetTester tester) => usarTela(tester, telaLarga);

/// Abre o app com a [autenticacao] falsa e o servidor "conectado", mais os [overrides] da tela
/// testada, e espera assentar. Com [tamanho] `null`, mantém a tela padrão do teste.
Future<void> abrirApp(
  WidgetTester tester, {
  required AutenticacaoFalsa autenticacao,
  List<Override> overrides = const [],
  Size? tamanho = telaLarga,
}) async {
  if (tamanho != null) usarTela(tester, tamanho);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        autenticacaoRepositoryProvider.overrideWithValue(autenticacao),
        apiSaudeProvider.overrideWith((ref) async => true),
        ...overrides,
      ],
      child: const OficinaFacilApp(),
    ),
  );
  await tester.pumpAndSettle();
}
