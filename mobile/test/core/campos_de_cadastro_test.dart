import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/core/widgets/campo_documento.dart';
import 'package:oficina_facil/core/widgets/campo_placa.dart';
import 'package:oficina_facil/core/widgets/campo_telefone.dart';

Future<GlobalKey<FormState>> _montar(
  WidgetTester tester,
  List<Widget> campos,
) async {
  final chave = GlobalKey<FormState>();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Form(
          key: chave,
          child: Column(children: campos),
        ),
      ),
    ),
  );
  return chave;
}

void main() {
  testWidgets('CampoDocumento aplica a máscara de CPF e de CNPJ', (
    tester,
  ) async {
    final controle = TextEditingController();
    await _montar(tester, [CampoDocumento(controller: controle)]);

    await tester.enterText(find.byType(TextFormField), '52998224725');
    expect(controle.text, '529.982.247-25');
    await tester.enterText(find.byType(TextFormField), '11222333000181');
    expect(controle.text, '11.222.333/0001-81');
    expect(find.text('CPF ou CNPJ'), findsOneWidget);
  });

  testWidgets('CampoDocumento valida os dígitos e mostra o erro no campo', (
    tester,
  ) async {
    final controle = TextEditingController();
    final chave = await _montar(tester, [CampoDocumento(controller: controle)]);

    expect(chave.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Informe o CPF ou CNPJ'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '52998224726');
    await tester.pump();
    expect(find.text('CPF ou CNPJ inválido'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '52998224725');
    await tester.pump();
    expect(chave.currentState!.validate(), isTrue);
  });

  testWidgets('CampoDocumento mostra o erro vindo da API', (tester) async {
    await _montar(tester, [
      CampoDocumento(
        controller: TextEditingController(text: '529.982.247-25'),
        erro: 'Este documento já está cadastrado.',
      ),
    ]);
    expect(find.text('Este documento já está cadastrado.'), findsOneWidget);
  });

  testWidgets('CampoTelefone aplica a máscara e exige DDD e número', (
    tester,
  ) async {
    final controle = TextEditingController();
    final chave = await _montar(tester, [CampoTelefone(controller: controle)]);

    await tester.enterText(find.byType(TextFormField), '119123');
    expect(controle.text, '(11) 9123');
    expect(chave.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.textContaining('Telefone inválido'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '11912345678');
    expect(controle.text, '(11) 91234-5678');
    expect(chave.currentState!.validate(), isTrue);
  });

  testWidgets('CampoPlaca deixa em maiúsculas e valida o formato', (
    tester,
  ) async {
    final controle = TextEditingController();
    final chave = await _montar(tester, [CampoPlaca(controller: controle)]);

    await tester.enterText(find.byType(TextFormField), 'abc-12');
    expect(controle.text, 'ABC12');
    expect(chave.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.textContaining('Placa inválida'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'abc1d23');
    expect(controle.text, 'ABC1D23');
    expect(chave.currentState!.validate(), isTrue);
  });

  testWidgets('os campos desabilitados não aceitam digitação', (tester) async {
    await _montar(tester, [
      CampoPlaca(controller: TextEditingController(), enabled: false),
    ]);
    final campo = tester.widget<TextField>(find.byType(TextField));
    expect(campo.enabled, isFalse);
  });
}
