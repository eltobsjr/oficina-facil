import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/core/network/api_exception.dart';
import 'package:oficina_facil/core/widgets/cartao_de_lista.dart';
import 'package:oficina_facil/features/clientes/presentation/providers/clientes_providers.dart';
import 'package:oficina_facil/features/veiculos/presentation/providers/veiculos_providers.dart';

import '../../helpers/abrir_app.dart';
import '../../helpers/autenticacao_falsa.dart';
import '../../helpers/campos.dart';
import '../../helpers/clientes_falso.dart';
import '../../helpers/veiculos_falso.dart';

ClientesFalso _clientes() => ClientesFalso([
  cliente('c1', nome: 'Ana Lima', documento: cpfAna),
  cliente('c2', nome: 'Bruno Alves', documento: cpfBruno),
  cliente('c3', nome: 'Carla Inativa', documento: '39053344705', ativo: false),
]);

VeiculosFalso _veiculos() => VeiculosFalso([
  veiculo(
    'v1',
    clienteId: 'c1',
    placa: 'ABC1234',
    marca: 'Fiat',
    modelo: 'Uno',
  ),
  veiculo(
    'v2',
    clienteId: 'c1',
    placa: 'DEF5G67',
    marca: 'VW',
    modelo: 'Gol',
    ano: 2020,
    cor: 'Prata',
    ativo: false,
  ),
  veiculo('v3', clienteId: 'c2', placa: 'JKL9012', marca: 'Ford', modelo: 'Ka'),
]);

/// Abre o app como atendente, entra no cliente Ana e vai para os veículos dela.
Future<void> _abrirVeiculos(
  WidgetTester tester,
  VeiculosFalso veiculos, {
  ClientesFalso? clientes,
}) async {
  await abrirApp(
    tester,
    autenticacao: AutenticacaoFalsa(sessaoInicial: usuarioAtendente),
    overrides: [
      clientesRepositoryProvider.overrideWithValue(clientes ?? _clientes()),
      veiculosRepositoryProvider.overrideWithValue(veiculos),
    ],
  );
  await tester.tap(find.widgetWithText(CartaoDeLista, 'Clientes'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Ana Lima'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Veículos do cliente'));
  await tester.pumpAndSettle();
}

Future<void> _novoVeiculo(WidgetTester tester) =>
    tocarBotao<FilledButton>(tester, 'Novo veículo');

Future<void> _salvar(WidgetTester tester) =>
    tocarBotao<FilledButton>(tester, 'Salvar');

Future<void> _preencher(
  WidgetTester tester, {
  String placa = 'abc1d23',
  String ano = '2018',
  String km = '42000',
}) async {
  await tester.enterText(campoDeTexto('Placa'), placa);
  await tester.enterText(campoDeTexto('Marca'), 'Renault');
  await tester.enterText(campoDeTexto('Modelo'), 'Kwid');
  await tester.enterText(campoDeTexto('Ano'), ano);
  await tester.enterText(campoDeTexto('Cor (opcional)'), 'Branco');
  await tester.enterText(campoDeTexto('Quilometragem'), km);
}

void main() {
  group('T07 veículos do cliente', () {
    testWidgets(
      'lista só os veículos do cliente, com o nome dele e quem está inativo',
      (tester) async {
        await _abrirVeiculos(tester, _veiculos());

        expect(find.text('Ana Lima'), findsOneWidget);
        expect(find.text('ABC1234'), findsOneWidget);
        expect(find.text('Fiat Uno · 2015'), findsOneWidget);
        expect(find.text('DEF5G67'), findsOneWidget);
        expect(find.text('JKL9012'), findsNothing);
        expect(find.text('Inativo'), findsOneWidget);
      },
    );

    testWidgets('cliente sem veículos mostra mensagem de lista vazia', (
      tester,
    ) async {
      await _abrirVeiculos(tester, VeiculosFalso([]));
      expect(find.text('Este cliente ainda não tem veículos.'), findsOneWidget);
    });

    testWidgets('erro de rede mostra a mensagem e permite tentar de novo', (
      tester,
    ) async {
      final fake = _veiculos();
      await _abrirVeiculos(tester, fake);
      fake.falharNaProxima = const SemConexaoException();
      await tester.tap(find.byTooltip('Voltar para o cliente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Veículos do cliente'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Sem conexão com o servidor'), findsOneWidget);
      await tester.tap(find.text('Tentar de novo'));
      await tester.pumpAndSettle();
      expect(find.text('ABC1234'), findsOneWidget);
    });
  });

  group('T07 cadastrar veículo', () {
    testWidgets(
      'CA03: campos vazios e placa inválida são recusados e nada é enviado',
      (tester) async {
        final fake = _veiculos();
        await _abrirVeiculos(tester, fake);
        await _novoVeiculo(tester);

        await _salvar(tester);
        expect(find.text('Informe a placa'), findsOneWidget);
        expect(find.text('Informe a marca'), findsOneWidget);
        expect(find.text('Informe o modelo'), findsOneWidget);
        expect(find.text('Informe o ano'), findsOneWidget);
        expect(find.text('Informe a quilometragem'), findsOneWidget);

        await _preencher(tester, placa: 'ab12');
        await _salvar(tester);
        expect(
          find.text('Placa inválida. Use ABC1234 ou ABC1D23.'),
          findsOneWidget,
        );
        expect(fake.criacoes, isEmpty);
      },
    );

    testWidgets('ano fora da faixa é recusado', (tester) async {
      final fake = _veiculos();
      await _abrirVeiculos(tester, fake);
      await _novoVeiculo(tester);

      await _preencher(tester, ano: '1800');
      await _salvar(tester);

      expect(find.textContaining('Ano inválido'), findsOneWidget);
      expect(fake.criacoes, isEmpty);
    });

    testWidgets(
      'CA01: cadastra vinculado ao cliente, com placa em maiúsculas, e volta à lista',
      (tester) async {
        final fake = _veiculos();
        await _abrirVeiculos(tester, fake);
        await _novoVeiculo(tester);

        await _preencher(tester);
        await _salvar(tester);

        final (clienteId, dados) = fake.criacoes.single;
        expect(clienteId, 'c1');
        expect(dados.placa, 'ABC1D23');
        expect(dados.marca, 'Renault');
        expect(dados.ano, 2018);
        expect(dados.cor, 'Branco');
        expect(dados.quilometragem, 42000);
        expect(find.text('Veículo cadastrado.'), findsOneWidget);
        expect(find.text('ABC1D23'), findsOneWidget, reason: 'voltou à lista');
      },
    );

    testWidgets(
      'CA02: placa repetida mostra o aviso e abre o veículo existente do outro dono',
      (tester) async {
        final fake = _veiculos();
        await _abrirVeiculos(tester, fake);
        await _novoVeiculo(tester);

        await _preencher(tester, placa: 'JKL9012');
        await _salvar(tester);

        expect(find.text('Esta placa já está cadastrada.'), findsOneWidget);
        expect(find.text('Novo veículo'), findsWidgets);

        await tester.tap(find.text('Abrir veículo existente'));
        await tester.pumpAndSettle();

        expect(find.text('Editar veículo'), findsOneWidget);
        expect(campoComValor('JKL9012'), findsOneWidget);
        expect(campoComValor('Ka'), findsOneWidget);
      },
    );
  });

  group('T07 editar, transferir e inativar', () {
    Future<void> abrirUno(WidgetTester tester, VeiculosFalso fake) async {
      await _abrirVeiculos(tester, fake);
      await tester.tap(find.text('ABC1234'));
      await tester.pumpAndSettle();
    }

    testWidgets('abre com os dados do veículo', (tester) async {
      await abrirUno(tester, _veiculos());

      expect(find.text('Editar veículo'), findsOneWidget);
      expect(campoComValor('ABC1234'), findsOneWidget);
      expect(campoComValor('Fiat'), findsOneWidget);
      expect(campoComValor('Uno'), findsOneWidget);
      expect(campoComValor('2015'), findsOneWidget);
      expect(campoComValor('80000'), findsOneWidget);
    });

    testWidgets('CA04: altera os dados e volta à lista', (tester) async {
      final fake = _veiculos();
      await abrirUno(tester, fake);

      await tester.enterText(campoDeTexto('Quilometragem'), '85000');
      await tester.enterText(campoDeTexto('Cor (opcional)'), 'Vermelho');
      await _salvar(tester);

      final (id, dados) = fake.alteracoes.single;
      expect(id, 'v1');
      expect(dados.quilometragem, 85000);
      expect(dados.cor, 'Vermelho');
      expect(find.text('Veículo atualizado.'), findsOneWidget);
    });

    testWidgets('inativa depois de confirmar', (tester) async {
      final fake = _veiculos();
      await abrirUno(tester, fake);

      await tester.tap(find.text('Inativar veículo'));
      await tester.pumpAndSettle();
      await tocarBotao<FilledButton>(tester, 'Inativar');

      expect(fake.inativados, ['v1']);
      expect(find.text('Veículo inativado.'), findsOneWidget);
      expect(find.text('Inativar veículo'), findsNothing);
    });

    testWidgets('cancelar a confirmação não inativa o veículo', (tester) async {
      final fake = _veiculos();
      await abrirUno(tester, fake);

      await tester.tap(find.text('Inativar veículo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(fake.inativados, isEmpty);
    });

    testWidgets(
      'CA05: transfere para outro cliente depois de confirmar e o veículo sai da lista',
      (tester) async {
        final fake = _veiculos();
        await abrirUno(tester, fake);

        await tester.tap(find.text('Transferir de dono'));
        await tester.pumpAndSettle();
        // O dono atual e os clientes inativos não aparecem como destino.
        expect(find.text('Ana Lima'), findsNothing);
        expect(find.text('Carla Inativa'), findsNothing);
        expect(find.text('Bruno Alves'), findsOneWidget);

        await tester.tap(find.text('Bruno Alves'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('continuam no nome do dono anterior'),
          findsOneWidget,
        );
        await tocarBotao<FilledButton>(tester, 'Transferir');

        expect(fake.transferencias.single, ('v1', 'c2'));
        expect(
          find.text('Veículo transferido para Bruno Alves.'),
          findsOneWidget,
        );
        expect(
          find.text('ABC1234'),
          findsNothing,
          reason: 'saiu da lista de Ana',
        );
      },
    );

    testWidgets('a busca do seletor filtra os clientes', (tester) async {
      final fake = _veiculos();
      await abrirUno(tester, fake);
      await tester.tap(find.text('Transferir de dono'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Buscar cliente por nome ou documento'),
        'zzzz',
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Nenhum cliente ativo encontrado.'), findsOneWidget);
    });

    testWidgets('cancelar a escolha do novo dono não transfere nada', (
      tester,
    ) async {
      final fake = _veiculos();
      await abrirUno(tester, fake);

      await tester.tap(find.text('Transferir de dono'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(fake.transferencias, isEmpty);
    });

    testWidgets('veículo que não existe mostra erro claro', (tester) async {
      final fake = _veiculos();
      await _abrirVeiculos(tester, fake);
      fake.veiculos.removeWhere((v) => v.id == 'v1');
      await tester.tap(find.text('ABC1234'));
      await tester.pumpAndSettle();

      expect(find.text('Não encontramos o que você procura.'), findsOneWidget);
    });
  });
}
