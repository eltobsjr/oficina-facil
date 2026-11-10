import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/core/widgets/campo_rotulado.dart';

/// Campo de texto do formulário que tem o [rotulo] visível acima dele.
Finder campoDeTexto(String rotulo) => find.descendant(
  of: find.widgetWithText(CampoRotulado, rotulo),
  matching: find.byType(TextFormField),
);

/// Campo de texto que mostra exatamente [texto] (o rótulo e a dica não contam).
Finder campoComValor(String texto) => find.byWidgetPredicate(
  (w) => w is EditableText && w.controller.text == texto,
);

/// Toca o botão do tipo [T] com o [texto] e espera a tela assentar.
Future<void> tocarBotao<T extends Widget>(
  WidgetTester tester,
  String texto,
) async {
  await tester.tap(find.widgetWithText(T, texto));
  await tester.pumpAndSettle();
}
