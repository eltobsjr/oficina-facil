import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/core/network/api_exception.dart';
import 'package:oficina_facil/core/shell/barra_de_abas.dart';
import 'package:oficina_facil/core/shell/barra_global.dart';
import 'package:oficina_facil/core/widgets/cartao_de_lista.dart';
import 'package:oficina_facil/core/widgets/sub_barra.dart';
import 'package:oficina_facil/core/widgets/tile_escuro.dart';
import 'package:oficina_facil/features/autenticacao/domain/entities/falha_login.dart';

import '../../helpers/abrir_app.dart';
import '../../helpers/autenticacao_falsa.dart';
import '../../helpers/campos.dart';

/// Tamanho de celular (estreito): o menu aparece embaixo. O padrão do teste (800 px) é "tela larga".
const _celular = Size(400, 800);

Future<void> _abrir(
  WidgetTester tester,
  AutenticacaoFalsa fake, {
  Size? tamanho,
}) => abrirApp(tester, autenticacao: fake, tamanho: tamanho);

Future<void> _preencherEEntrar(
  WidgetTester tester, {
  String email = 'ana@teste.local',
  String senha = 'senha-forte-1',
}) async {
  await tester.enterText(campoDeTexto('E-mail'), email);
  await tester.enterText(campoDeTexto('Senha'), senha);
  await tocarBotao<FilledButton>(tester, 'Entrar');
}

void main() {
  group('T01 Login', () {
    testWidgets('sem sessão o app abre no login', (tester) async {
      await _abrir(tester, AutenticacaoFalsa());

      expect(find.text('Entrar'), findsWidgets);
      expect(campoDeTexto('E-mail'), findsOneWidget);
      expect(campoDeTexto('Senha'), findsOneWidget);
    });

    testWidgets('campos vazios mostram o que falta e não chamam o servidor', (
      tester,
    ) async {
      final fake = AutenticacaoFalsa();
      await _abrir(tester, fake);

      await tocarBotao<FilledButton>(tester, 'Entrar');

      expect(find.text('Informe o e-mail'), findsOneWidget);
      expect(find.text('Informe a senha'), findsOneWidget);
    });

    testWidgets('e-mail sem @ é recusado antes de chamar o servidor', (
      tester,
    ) async {
      await _abrir(tester, AutenticacaoFalsa());

      await _preencherEEntrar(tester, email: 'sem-arroba');

      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('credencial errada mostra mensagem genérica', (tester) async {
      final fake = AutenticacaoFalsa()
        ..falhaAoEntrar = const CredenciaisInvalidas();
      await _abrir(tester, fake);

      await _preencherEEntrar(tester);

      expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
      expect(find.text('Olá, Ana Atendente'), findsNothing);
    });

    testWidgets('usuário desativado mostra aviso próprio', (tester) async {
      final fake = AutenticacaoFalsa()
        ..falhaAoEntrar = const UsuarioDesativado();
      await _abrir(tester, fake);

      await _preencherEEntrar(tester);

      expect(
        find.text('Este usuário está desativado. Procure o gerente.'),
        findsOneWidget,
      );
    });

    testWidgets('usuário sem perfil mostra aviso próprio', (tester) async {
      final fake = AutenticacaoFalsa()
        ..falhaAoEntrar = const UsuarioSemPerfil();
      await _abrir(tester, fake);

      await _preencherEEntrar(tester);

      expect(
        find.text('Este usuário não tem perfil cadastrado. Procure o gerente.'),
        findsOneWidget,
      );
    });

    testWidgets('sem rede mostra mensagem de conexão', (tester) async {
      final fake = AutenticacaoFalsa()
        ..falhaAoEntrar = const SemConexaoException();
      await _abrir(tester, fake);

      await _preencherEEntrar(tester);

      expect(find.textContaining('Sem conexão com o servidor'), findsOneWidget);
    });

    testWidgets('a senha começa oculta e o botão alterna a visibilidade', (
      tester,
    ) async {
      await _abrir(tester, AutenticacaoFalsa());

      EditableText campo() => tester.widget<EditableText>(
        find.descendant(
          of: campoDeTexto('Senha'),
          matching: find.byType(EditableText),
        ),
      );
      expect(campo().obscureText, isTrue);

      await tester.tap(find.byTooltip('Mostrar senha'));
      await tester.pump();

      expect(campo().obscureText, isFalse);
    });

    testWidgets('login correto leva ao início do perfil', (tester) async {
      final fake = AutenticacaoFalsa(usuarioDoLogin: usuarioAtendente);
      await _abrir(tester, fake);

      await _preencherEEntrar(tester);

      expect(find.text('Olá, Ana Atendente'), findsOneWidget);
      expect(find.text('Atendente'), findsWidgets);
    });
  });

  group('sessão guardada', () {
    testWidgets('abre direto no início, sem passar pelo login', (tester) async {
      await _abrir(tester, AutenticacaoFalsa(sessaoInicial: usuarioGerente));

      expect(find.text('Olá, Gerente Um'), findsOneWidget);
      expect(campoDeTexto('E-mail'), findsNothing);
    });

    testWidgets('sem rede ao abrir, oferece tentar de novo e depois entra', (
      tester,
    ) async {
      final fake = AutenticacaoFalsa(sessaoInicial: usuarioGerente)
        ..falhaAoCarregar = const SemConexaoException();
      await _abrir(tester, fake);

      expect(find.text('Sem conexão'), findsOneWidget);
      expect(find.text('Tentar de novo'), findsOneWidget);

      fake.falhaAoCarregar = null;
      await tester.tap(find.text('Tentar de novo'));
      await tester.pumpAndSettle();

      expect(find.text('Olá, Gerente Um'), findsOneWidget);
    });
  });

  group('T02 Início e menu por perfil', () {
    testWidgets('o gerente vê o atalho e o item de menu Usuários', (
      tester,
    ) async {
      await _abrir(
        tester,
        AutenticacaoFalsa(sessaoInicial: usuarioGerente),
        tamanho: _celular,
      );

      expect(find.widgetWithText(CartaoDeLista, 'Usuários'), findsOneWidget);
      expect(find.byType(BarraDeAbas), findsOneWidget);
    });

    testWidgets(
      'o atendente vê Clientes no menu e no atalho, mas não Usuários',
      (tester) async {
        await _abrir(
          tester,
          AutenticacaoFalsa(sessaoInicial: usuarioAtendente),
          tamanho: _celular,
        );

        expect(find.text('Usuários'), findsNothing);
        expect(find.byType(BarraDeAbas), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(BarraDeAbas),
            matching: find.text('Clientes'),
          ),
          findsOneWidget,
        );
        expect(find.widgetWithText(CartaoDeLista, 'Clientes'), findsOneWidget);
      },
    );

    testWidgets(
      'a moldura tem barra global com a conta e sub-barra com o título',
      (tester) async {
        await _abrir(
          tester,
          AutenticacaoFalsa(sessaoInicial: usuarioAtendente),
        );

        expect(find.byType(BarraGlobal), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(BarraGlobal),
            matching: find.text('Ana Atendente · Atendente'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(SubBarra),
            matching: find.text('Início'),
          ),
          findsOneWidget,
        );
        expect(find.byType(AppBar), findsNothing);
      },
    );

    testWidgets('o início mostra o tile escuro com a saudação e o perfil', (
      tester,
    ) async {
      await _abrir(tester, AutenticacaoFalsa(sessaoInicial: usuarioGerente));

      expect(
        find.descendant(
          of: find.byType(TileEscuro),
          matching: find.text('Olá, Gerente Um'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(TileEscuro),
          matching: find.text('Gerente'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('mostra se o servidor está conectado', (tester) async {
      await _abrir(tester, AutenticacaoFalsa(sessaoInicial: usuarioAtendente));

      expect(find.text('Servidor conectado'), findsOneWidget);
    });

    testWidgets('Sair encerra a sessão e volta ao login', (tester) async {
      final fake = AutenticacaoFalsa(sessaoInicial: usuarioAtendente);
      await _abrir(tester, fake);

      await tester.tap(find.byTooltip('Conta'));
      await tester.pumpAndSettle();
      expect(find.text('Ana Atendente · Atendente'), findsOneWidget);
      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();

      expect(fake.saidas, 1);
      expect(campoDeTexto('E-mail'), findsOneWidget);
    });

    testWidgets('em tela larga o menu vira barra lateral', (tester) async {
      await _abrir(
        tester,
        AutenticacaoFalsa(sessaoInicial: usuarioGerente),
        tamanho: const Size(1200, 800),
      );

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(BarraDeAbas), findsNothing);
    });

    testWidgets('abre em português do Brasil', (tester) async {
      await _abrir(tester, AutenticacaoFalsa());

      final contexto = tester.element(find.byType(Scaffold));
      expect(Localizations.localeOf(contexto), const Locale('pt', 'BR'));
      expect(MaterialLocalizations.of(contexto).cancelButtonLabel, 'Cancelar');
    });
  });
}
