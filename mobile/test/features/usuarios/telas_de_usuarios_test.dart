import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/core/network/api_exception.dart';
import 'package:oficina_facil/core/perfil.dart';
import 'package:oficina_facil/core/widgets/cartao_de_lista.dart';
import 'package:oficina_facil/features/usuarios/presentation/providers/usuarios_providers.dart';

import '../../helpers/abrir_app.dart';
import '../../helpers/autenticacao_falsa.dart';
import '../../helpers/campos.dart';
import '../../helpers/usuarios_falso.dart';

UsuariosFalso _repositorio() => UsuariosFalso([
  usuario('g1', nome: 'Gerente Um', perfil: Perfil.gerente),
  usuario('a1', nome: 'Ana Atendente'),
  usuario('m1', nome: 'Marcos Mecânico', perfil: Perfil.mecanico),
  usuario('x1', nome: 'Xuxa Inativa', ativo: false),
]);

/// Abre o app como gerente e entra em Usuários pelo atalho da tela inicial.
Future<void> _abrirUsuarios(WidgetTester tester, UsuariosFalso fake) async {
  await abrirApp(
    tester,
    autenticacao: AutenticacaoFalsa(sessaoInicial: usuarioGerente),
    overrides: [usuariosRepositoryProvider.overrideWithValue(fake)],
  );
  await tester.tap(find.widgetWithText(CartaoDeLista, 'Usuários'));
  await tester.pumpAndSettle();
}

/// Toca num chip da fileira de filtros, que rola na horizontal: leva o chip à tela antes.
Future<void> _tocarChip(WidgetTester tester, String rotulo) async {
  final chip = find.widgetWithText(ChoiceChip, rotulo);
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

Future<void> _escolherPerfil(WidgetTester tester, String rotulo) async {
  await tester.tap(find.byType(DropdownButtonFormField<Perfil>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(rotulo).last);
  await tester.pumpAndSettle();
}

void main() {
  group('T03 lista de usuários', () {
    testWidgets('mostra os usuários, o perfil e quem está inativo', (
      tester,
    ) async {
      await _abrirUsuarios(tester, _repositorio());

      expect(find.text('Gerente Um'), findsOneWidget);
      expect(find.text('Ana Atendente'), findsOneWidget);
      expect(find.text('ana-atendente'), findsNothing);
      expect(find.textContaining('Mecânico'), findsWidgets);
      expect(find.text('Inativo'), findsOneWidget);
    });

    testWidgets('mostra mensagem quando não há resultados', (tester) async {
      await _abrirUsuarios(tester, UsuariosFalso([]));
      expect(find.text('Nenhum usuário encontrado.'), findsOneWidget);
    });

    testWidgets('erro de rede mostra a mensagem e permite tentar de novo', (
      tester,
    ) async {
      final fake = _repositorio()
        ..falharNaProxima = const SemConexaoException();
      await _abrirUsuarios(tester, fake);

      expect(find.textContaining('Sem conexão com o servidor'), findsOneWidget);

      await tester.tap(find.text('Tentar de novo'));
      await tester.pumpAndSettle();

      expect(find.text('Gerente Um'), findsOneWidget);
    });

    testWidgets('busca só consulta depois que o usuário para de digitar', (
      tester,
    ) async {
      final fake = _repositorio();
      await _abrirUsuarios(tester, fake);
      final antes = fake.listagens.length;

      await tester.enterText(find.byType(TextField).first, 'm');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField).first, 'marc');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(fake.listagens.length, antes + 1, reason: 'uma consulta só');
      expect(fake.listagens.last.$1.texto, 'marc');
      expect(find.text('Marcos Mecânico'), findsOneWidget);
      expect(find.text('Ana Atendente'), findsNothing);
    });

    testWidgets('a busca só dispara depois de 400 ms sem digitar', (
      tester,
    ) async {
      final fake = _repositorio();
      await _abrirUsuarios(tester, fake);
      final antes = fake.listagens.length;

      await tester.enterText(find.byType(TextField).first, 'marc');
      await tester.pump(const Duration(milliseconds: 399));
      expect(fake.listagens.length, antes, reason: 'ainda esperando');

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
      expect(fake.listagens.length, antes + 1);
      expect(fake.listagens.last.$1.texto, 'marc');
    });

    testWidgets(
      'falha ao carregar mais mostra "Tentar carregar mais" e a tentativa '
      'seguinte completa a lista',
      (tester) async {
        final fake = UsuariosFalso([
          for (var i = 1; i <= 40; i++) usuario('u$i', nome: 'Usuário $i'),
        ], tamanhoDaPagina: 20);
        await _abrirUsuarios(tester, fake);
        expect(find.text('Tentar carregar mais'), findsNothing);

        fake.falharPaginasSeguintes = true;
        await tester.drag(find.byType(ListView), const Offset(0, -1500));
        await tester.pumpAndSettle();

        expect(fake.listagens.last.$2, 2);
        expect(find.text('Tentar carregar mais'), findsOneWidget);

        fake.falharPaginasSeguintes = false;
        await tester.tap(find.text('Tentar carregar mais'));
        await tester.pumpAndSettle();

        expect(find.text('Tentar carregar mais'), findsNothing);
        expect(fake.listagens.last.$2, 2, reason: 'a tentativa deu certo');
      },
    );

    testWidgets('filtra por perfil e por situação', (tester) async {
      await _abrirUsuarios(tester, _repositorio());

      await _tocarChip(tester, 'Mecânico');
      expect(find.text('Marcos Mecânico'), findsOneWidget);
      expect(find.text('Ana Atendente'), findsNothing);

      await _tocarChip(tester, 'Todos os perfis');
      await _tocarChip(tester, 'Inativos');
      expect(find.text('Xuxa Inativa'), findsOneWidget);
      expect(find.text('Ana Atendente'), findsNothing);

      await _tocarChip(tester, 'Inativos');
      expect(find.text('Ana Atendente'), findsOneWidget);
    });
  });

  group('T04 criar usuário', () {
    testWidgets('o botão Novo usuário abre o formulário', (tester) async {
      await _abrirUsuarios(tester, _repositorio());
      await tocarBotao<FilledButton>(tester, 'Novo usuário');

      expect(find.text('Novo usuário'), findsOneWidget);
      expect(campoDeTexto('Senha inicial'), findsOneWidget);
    });

    testWidgets('campos vazios mostram o que falta e nada é enviado', (
      tester,
    ) async {
      final fake = _repositorio();
      await _abrirUsuarios(tester, fake);
      await tocarBotao<FilledButton>(tester, 'Novo usuário');

      await tocarBotao<FilledButton>(tester, 'Salvar');

      expect(find.text('Informe o nome'), findsOneWidget);
      expect(find.text('Informe o e-mail'), findsOneWidget);
      expect(find.text('Escolha o perfil'), findsOneWidget);
      expect(
        find.text('A senha precisa ter pelo menos 8 caracteres'),
        findsOneWidget,
      );
      expect(fake.criacoes, isEmpty);
    });

    testWidgets('cria o usuário, avisa e volta para a lista com ele', (
      tester,
    ) async {
      final fake = _repositorio();
      await _abrirUsuarios(tester, fake);
      await tocarBotao<FilledButton>(tester, 'Novo usuário');

      await tester.enterText(campoDeTexto('Nome'), 'Nova Pessoa');
      await tester.enterText(campoDeTexto('E-mail'), 'nova@teste.local');
      await _escolherPerfil(tester, 'Almoxarife');
      await tester.enterText(campoDeTexto('Senha inicial'), 'senha-forte-1');
      await tocarBotao<FilledButton>(tester, 'Salvar');

      expect(fake.criacoes.single, {
        'nome': 'Nova Pessoa',
        'email': 'nova@teste.local',
        'perfil': Perfil.almoxarife,
        'senha': 'senha-forte-1',
      });
      expect(find.text('Usuário criado.'), findsOneWidget);
      expect(
        find.text('Nova Pessoa'),
        findsOneWidget,
        reason: 'voltou à lista',
      );
    });

    testWidgets('e-mail repetido mostra o erro no próprio campo', (
      tester,
    ) async {
      final fake = _repositorio();
      await _abrirUsuarios(tester, fake);
      await tocarBotao<FilledButton>(tester, 'Novo usuário');
      await tester.enterText(campoDeTexto('Nome'), 'Nova Pessoa');
      await tester.enterText(campoDeTexto('E-mail'), 'a1@teste.local');
      await _escolherPerfil(tester, 'Mecânico');
      await tester.enterText(campoDeTexto('Senha inicial'), 'senha-forte-1');

      fake.falharNaProxima = const ApiException(
        status: 409,
        codigo: 'conflito',
        mensagem: 'E-mail já cadastrado',
      );
      await tocarBotao<FilledButton>(tester, 'Salvar');

      expect(find.text('E-mail já cadastrado'), findsOneWidget);
      expect(
        find.text('Novo usuário'),
        findsOneWidget,
        reason: 'continua no formulário',
      );
    });
  });

  group('T04 editar usuário', () {
    Future<void> abrirAna(WidgetTester tester, UsuariosFalso fake) async {
      await _abrirUsuarios(tester, fake);
      await tester.tap(find.text('Ana Atendente'));
      await tester.pumpAndSettle();
    }

    testWidgets('abre com os dados e o e-mail não pode ser alterado', (
      tester,
    ) async {
      await abrirAna(tester, _repositorio());

      expect(find.text('Editar usuário'), findsOneWidget);
      expect(find.text('Ana Atendente'), findsOneWidget);
      final email = tester.widget<TextField>(
        find.descendant(
          of: campoDeTexto('E-mail'),
          matching: find.byType(TextField),
        ),
      );
      expect(email.enabled, isFalse);
      expect(find.text('Senha inicial'), findsNothing);
    });

    testWidgets('salva o novo nome e o novo perfil', (tester) async {
      final fake = _repositorio();
      await abrirAna(tester, fake);

      await tester.enterText(campoDeTexto('Nome'), 'Ana Souza');
      await _escolherPerfil(tester, 'Almoxarife');
      await tocarBotao<FilledButton>(tester, 'Salvar');

      expect(fake.alteracoes.single, {
        'id': 'a1',
        'nome': 'Ana Souza',
        'perfil': Perfil.almoxarife,
      });
      expect(find.text('Usuário atualizado.'), findsOneWidget);
    });

    testWidgets('inativa depois de confirmar e passa a oferecer reativar', (
      tester,
    ) async {
      final fake = _repositorio();
      await abrirAna(tester, fake);

      await tester.tap(find.text('Inativar usuário'));
      await tester.pumpAndSettle();
      expect(find.textContaining('não conseguirá mais entrar'), findsOneWidget);
      await tocarBotao<FilledButton>(tester, 'Inativar');

      expect(fake.inativados, ['a1']);
      expect(find.text('Usuário inativado.'), findsOneWidget);
      expect(find.text('Reativar usuário'), findsOneWidget);
    });

    testWidgets('cancelar a confirmação não inativa ninguém', (tester) async {
      final fake = _repositorio();
      await abrirAna(tester, fake);

      await tester.tap(find.text('Inativar usuário'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(fake.inativados, isEmpty);
    });

    testWidgets('reativa um usuário inativo', (tester) async {
      final fake = _repositorio();
      await _abrirUsuarios(tester, fake);
      await tester.tap(find.text('Xuxa Inativa'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reativar usuário'));
      await tester.pumpAndSettle();
      await tocarBotao<FilledButton>(tester, 'Reativar');

      expect(fake.ativados, ['x1']);
      expect(find.text('Inativar usuário'), findsOneWidget);
    });

    testWidgets('o último gerente não pode ser inativado e a tela explica', (
      tester,
    ) async {
      final fake = _repositorio();
      await _abrirUsuarios(tester, fake);
      await tester.tap(find.text('Gerente Um'));
      await tester.pumpAndSettle();

      fake.falharNaProxima = const ApiException(
        status: 409,
        codigo: 'ultimo_gerente',
        mensagem: 'x',
      );
      await tester.tap(find.text('Inativar usuário'));
      await tester.pumpAndSettle();
      await tocarBotao<FilledButton>(tester, 'Inativar');

      expect(
        find.text('Não é possível: este é o último gerente ativo.'),
        findsOneWidget,
      );
      expect(find.text('Inativar usuário'), findsOneWidget);
    });

    testWidgets('redefinir senha exige 8 caracteres e depois confirma', (
      tester,
    ) async {
      final fake = _repositorio();
      await abrirAna(tester, fake);

      await tester.tap(find.text('Redefinir senha'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).last, 'curta');
      await tocarBotao<FilledButton>(tester, 'Redefinir');
      expect(
        find.text('A senha precisa ter pelo menos 8 caracteres'),
        findsOneWidget,
      );
      expect(fake.senhas, isEmpty);

      await tester.enterText(find.byType(TextFormField).last, 'senha-nova-9');
      await tocarBotao<FilledButton>(tester, 'Redefinir');

      expect(fake.senhas, ['senha-nova-9']);
      expect(find.text('Senha redefinida.'), findsOneWidget);
    });

    testWidgets('usuário que não existe mostra erro claro', (tester) async {
      final fake = _repositorio();
      await _abrirUsuarios(tester, fake);
      fake.usuarios.removeWhere((u) => u.id == 'a1');
      await tester.tap(find.text('Ana Atendente'));
      await tester.pumpAndSettle();

      expect(find.text('Não encontramos o que você procura.'), findsOneWidget);
    });
  });
}
