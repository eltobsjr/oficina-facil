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

ClientesFalso _repositorio() => ClientesFalso([
  cliente('c1', nome: 'Ana Lima', documento: cpfAna, email: 'ana@teste.local'),
  cliente(
    'c2',
    nome: 'Bruno Alves',
    documento: cpfBruno,
    telefone: '1133334444',
  ),
  cliente('c3', nome: 'Carla Inativa', documento: '39053344705', ativo: false),
]);

/// Abre o app como atendente e entra em Clientes pelo atalho da tela inicial.
Future<void> _abrirClientes(
  WidgetTester tester,
  ClientesFalso fake, {
  VeiculosFalso? veiculos,
}) async {
  await abrirApp(
    tester,
    autenticacao: AutenticacaoFalsa(sessaoInicial: usuarioAtendente),
    overrides: [
      clientesRepositoryProvider.overrideWithValue(fake),
      veiculosRepositoryProvider.overrideWithValue(
        veiculos ?? VeiculosFalso([]),
      ),
    ],
  );
  await tester.tap(find.widgetWithText(CartaoDeLista, 'Clientes'));
  await tester.pumpAndSettle();
}

Future<void> _novoCliente(WidgetTester tester) =>
    tocarBotao<FilledButton>(tester, 'Novo cliente');

Future<void> _salvar(WidgetTester tester) =>
    tocarBotao<FilledButton>(tester, 'Salvar');

void main() {
  group('T05 lista de clientes', () {
    testWidgets(
      'mostra nome, documento e telefone com máscara, e quem está inativo',
      (tester) async {
        await _abrirClientes(tester, _repositorio());

        expect(find.text('Ana Lima'), findsOneWidget);
        expect(find.text('529.982.247-25 · (11) 91234-5678'), findsOneWidget);
        expect(find.text('111.444.777-35 · (11) 3333-4444'), findsOneWidget);
        expect(find.text('Inativo'), findsOneWidget);
      },
    );

    testWidgets('sem clientes mostra mensagem de lista vazia', (tester) async {
      await _abrirClientes(tester, ClientesFalso([]));
      expect(find.text('Nenhum cliente cadastrado ainda.'), findsOneWidget);
    });

    testWidgets('erro de rede mostra a mensagem e permite tentar de novo', (
      tester,
    ) async {
      final fake = _repositorio()
        ..falharNaProxima = const SemConexaoException();
      await _abrirClientes(tester, fake);

      expect(find.textContaining('Sem conexão com o servidor'), findsOneWidget);

      await tester.tap(find.text('Tentar de novo'));
      await tester.pumpAndSettle();

      expect(find.text('Ana Lima'), findsOneWidget);
    });

    testWidgets('busca por nome só consulta quando o usuário para de digitar', (
      tester,
    ) async {
      final fake = _repositorio();
      await _abrirClientes(tester, fake);
      final antes = fake.listagens.length;

      await tester.enterText(find.byType(TextField).first, 'b');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField).first, 'bruno');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(fake.listagens.length, antes + 1, reason: 'uma consulta só');
      expect(fake.listagens.last.$1, 'bruno');
      expect(find.text('Bruno Alves'), findsOneWidget);
      expect(find.text('Ana Lima'), findsNothing);
    });

    testWidgets('a busca só dispara depois de 400 ms sem digitar', (
      tester,
    ) async {
      final fake = _repositorio();
      await _abrirClientes(tester, fake);
      final antes = fake.listagens.length;

      await tester.enterText(find.byType(TextField).first, 'bruno');
      await tester.pump(const Duration(milliseconds: 399));
      expect(fake.listagens.length, antes, reason: 'ainda esperando');

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
      expect(fake.listagens.length, antes + 1);
      expect(fake.listagens.last.$1, 'bruno');
    });

    testWidgets(
      'falha ao carregar mais mostra "Tentar carregar mais" e a tentativa '
      'seguinte completa a lista',
      (tester) async {
        final fake = ClientesFalso([
          for (var i = 1; i <= 40; i++)
            cliente('c$i', nome: 'Cliente $i', documento: '000000000$i'),
        ], tamanhoDaPagina: 20);
        await _abrirClientes(tester, fake);
        expect(find.text('Tentar carregar mais'), findsNothing);

        fake.falharPaginasSeguintes = true;
        await tester.drag(find.byType(ListView), const Offset(0, -1500));
        await tester.pumpAndSettle();

        expect(fake.listagens.last, ('', 2));
        expect(find.text('Tentar carregar mais'), findsOneWidget);

        fake.falharPaginasSeguintes = false;
        await tester.tap(find.text('Tentar carregar mais'));
        await tester.pumpAndSettle();

        expect(find.text('Tentar carregar mais'), findsNothing);
        expect(fake.listagens.last.$2, 2, reason: 'a tentativa deu certo');
      },
    );

    testWidgets('busca por documento encontra o cliente', (tester) async {
      await _abrirClientes(tester, _repositorio());

      await tester.enterText(find.byType(TextField).first, '529.982');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Ana Lima'), findsOneWidget);
      expect(find.text('Bruno Alves'), findsNothing);
    });

    testWidgets('busca sem resultado explica que nada foi encontrado', (
      tester,
    ) async {
      await _abrirClientes(tester, _repositorio());
      await tester.enterText(find.byType(TextField).first, 'zzzz');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(
        find.text('Nenhum cliente encontrado para essa busca.'),
        findsOneWidget,
      );
    });
  });

  group('T06 cadastrar cliente', () {
    testWidgets('o botão Novo cliente abre o formulário', (tester) async {
      await _abrirClientes(tester, _repositorio());
      await _novoCliente(tester);

      expect(find.text('Novo cliente'), findsOneWidget);
      expect(campoDeTexto('CPF ou CNPJ'), findsOneWidget);
      expect(campoDeTexto('Telefone'), findsOneWidget);
    });

    testWidgets(
      'CA03: campos obrigatórios ausentes são destacados e nada é enviado',
      (tester) async {
        final fake = _repositorio();
        await _abrirClientes(tester, fake);
        await _novoCliente(tester);

        await _salvar(tester);

        expect(find.text('Informe o nome'), findsOneWidget);
        expect(find.text('Informe o CPF ou CNPJ'), findsOneWidget);
        expect(find.text('Informe o telefone'), findsOneWidget);
        expect(fake.criacoes, isEmpty);
      },
    );

    testWidgets(
      'documento inválido e e-mail inválido são recusados no próprio campo',
      (tester) async {
        final fake = _repositorio();
        await _abrirClientes(tester, fake);
        await _novoCliente(tester);

        await tester.enterText(campoDeTexto('Nome'), 'Daniel Ramos');
        await tester.enterText(campoDeTexto('CPF ou CNPJ'), '52998224726');
        await tester.enterText(campoDeTexto('Telefone'), '11912345678');
        await tester.enterText(campoDeTexto('E-mail (opcional)'), 'sem-arroba');
        await _salvar(tester);

        expect(find.text('CPF ou CNPJ inválido'), findsOneWidget);
        expect(find.text('E-mail inválido'), findsOneWidget);
        expect(fake.criacoes, isEmpty);
      },
    );

    testWidgets(
      'CA01: cadastra com documento e telefone só com dígitos e volta à lista',
      (tester) async {
        final fake = _repositorio();
        await _abrirClientes(tester, fake);
        await _novoCliente(tester);

        await tester.enterText(campoDeTexto('Nome'), 'Daniel Ramos');
        await tester.enterText(campoDeTexto('CPF ou CNPJ'), '12345678909');
        await tester.enterText(campoDeTexto('Telefone'), '11987654321');
        await tester.enterText(
          campoDeTexto('E-mail (opcional)'),
          'daniel@teste.local',
        );
        await tester.enterText(
          campoDeTexto('Endereço (opcional)'),
          'Rua Fictícia, 5',
        );
        await _salvar(tester);

        final dados = fake.criacoes.single;
        expect(dados.nome, 'Daniel Ramos');
        expect(dados.documento, '12345678909');
        expect(dados.telefone, '11987654321');
        expect(dados.email, 'daniel@teste.local');
        expect(dados.endereco, 'Rua Fictícia, 5');
        expect(find.text('Cliente cadastrado.'), findsOneWidget);
        expect(
          find.text('Daniel Ramos'),
          findsOneWidget,
          reason: 'voltou à lista',
        );
      },
    );

    testWidgets('e-mail e endereço em branco são enviados como nulos', (
      tester,
    ) async {
      final fake = _repositorio();
      await _abrirClientes(tester, fake);
      await _novoCliente(tester);

      await tester.enterText(campoDeTexto('Nome'), 'Daniel Ramos');
      await tester.enterText(campoDeTexto('CPF ou CNPJ'), '12345678909');
      await tester.enterText(campoDeTexto('Telefone'), '1133334444');
      await _salvar(tester);

      expect(fake.criacoes.single.email, isNull);
      expect(fake.criacoes.single.endereco, isNull);
    });

    testWidgets(
      'CA02: documento repetido mostra o cadastro existente e oferece abri-lo',
      (tester) async {
        final fake = _repositorio();
        await _abrirClientes(tester, fake);
        await _novoCliente(tester);

        await tester.enterText(campoDeTexto('Nome'), 'Outra Pessoa');
        await tester.enterText(campoDeTexto('CPF ou CNPJ'), cpfAna);
        await tester.enterText(campoDeTexto('Telefone'), '11912345678');
        await _salvar(tester);

        expect(
          find.text('Este documento já está cadastrado para Ana Lima.'),
          findsOneWidget,
        );
        expect(
          find.text('Novo cliente'),
          findsOneWidget,
          reason: 'não saiu do formulário',
        );

        await tester.tap(find.text('Abrir cadastro existente'));
        await tester.pumpAndSettle();

        expect(find.text('Editar cliente'), findsOneWidget);
        expect(campoComValor('Ana Lima'), findsOneWidget);
      },
    );

    testWidgets('erro de rede ao salvar mostra a mensagem e mantém os dados', (
      tester,
    ) async {
      final fake = _repositorio();
      await _abrirClientes(tester, fake);
      await _novoCliente(tester);
      await tester.enterText(campoDeTexto('Nome'), 'Daniel Ramos');
      await tester.enterText(campoDeTexto('CPF ou CNPJ'), '12345678909');
      await tester.enterText(campoDeTexto('Telefone'), '1133334444');

      fake.falharNaProxima = const SemConexaoException();
      await _salvar(tester);

      expect(find.textContaining('Sem conexão com o servidor'), findsOneWidget);
      expect(campoComValor('Daniel Ramos'), findsOneWidget);
    });
  });

  group('T06 editar cliente', () {
    Future<void> abrirAna(WidgetTester tester, ClientesFalso fake) async {
      await _abrirClientes(tester, fake);
      await tester.tap(find.text('Ana Lima'));
      await tester.pumpAndSettle();
    }

    testWidgets('abre com os dados do cliente já com máscara', (tester) async {
      await abrirAna(tester, _repositorio());

      expect(find.text('Editar cliente'), findsOneWidget);
      expect(campoComValor('Ana Lima'), findsOneWidget);
      expect(campoComValor('529.982.247-25'), findsOneWidget);
      expect(campoComValor('(11) 91234-5678'), findsOneWidget);
      expect(campoComValor('ana@teste.local'), findsOneWidget);
    });

    testWidgets('CA04: altera os dados e avisa', (tester) async {
      final fake = _repositorio();
      await abrirAna(tester, fake);

      await tester.enterText(campoDeTexto('Telefone'), '11999990000');
      await tester.enterText(campoDeTexto('E-mail (opcional)'), '');
      await _salvar(tester);

      final (id, dados) = fake.alteracoes.single;
      expect(id, 'c1');
      expect(dados.telefone, '11999990000');
      expect(dados.email, isNull);
      expect(find.text('Cliente atualizado.'), findsOneWidget);
    });

    testWidgets('CA05: inativa depois de confirmar e mostra que está inativo', (
      tester,
    ) async {
      final fake = _repositorio();
      await abrirAna(tester, fake);

      await tester.tap(find.text('Inativar cliente'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('histórico de OS são mantidos'),
        findsOneWidget,
      );
      await tocarBotao<FilledButton>(tester, 'Inativar');

      expect(fake.inativados, ['c1']);
      expect(find.text('Cliente inativado.'), findsOneWidget);
      expect(find.text('Inativo'), findsWidgets);
      expect(find.text('Inativar cliente'), findsNothing);
    });

    testWidgets('cancelar a confirmação não inativa ninguém', (tester) async {
      final fake = _repositorio();
      await abrirAna(tester, fake);

      await tester.tap(find.text('Inativar cliente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(fake.inativados, isEmpty);
    });

    testWidgets('cliente com OS ativa não é inativado e a tela explica', (
      tester,
    ) async {
      final fake = _repositorio();
      await abrirAna(tester, fake);

      fake.falharNaProxima = const ApiException(
        status: 409,
        codigo: 'cliente_com_os_ativa',
        mensagem: 'Não é possível inativar: o cliente tem OS em andamento',
      );
      await tester.tap(find.text('Inativar cliente'));
      await tester.pumpAndSettle();
      await tocarBotao<FilledButton>(tester, 'Inativar');

      expect(
        find.text('Não é possível inativar: o cliente tem OS em andamento'),
        findsOneWidget,
      );
      expect(find.text('Inativar cliente'), findsOneWidget);
    });

    testWidgets('cliente que não existe mostra erro claro', (tester) async {
      final fake = _repositorio();
      await _abrirClientes(tester, fake);
      fake.clientes.removeWhere((c) => c.id == 'c2');
      await tester.tap(find.text('Bruno Alves'));
      await tester.pumpAndSettle();

      expect(find.text('Não encontramos o que você procura.'), findsOneWidget);
    });

    testWidgets('o botão Veículos do cliente abre a lista de veículos', (
      tester,
    ) async {
      final veiculos = VeiculosFalso([veiculo('v1', clienteId: 'c1')]);
      await _abrirClientes(tester, _repositorio(), veiculos: veiculos);
      await tester.tap(find.text('Ana Lima'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Veículos do cliente'));
      await tester.pumpAndSettle();

      expect(find.text('Ana Lima'), findsOneWidget);
      expect(find.text('ABC1234'), findsOneWidget);
    });
  });
}
