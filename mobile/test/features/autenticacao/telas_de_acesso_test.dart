import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/app.dart';
import 'package:oficina_facil/core/network/api_client.dart';
import 'package:oficina_facil/core/network/api_exception.dart';
import 'package:oficina_facil/features/autenticacao/domain/entities/falha_login.dart';
import 'package:oficina_facil/features/autenticacao/presentation/providers/sessao_provider.dart';

import '../../helpers/autenticacao_falsa.dart';

Widget _app(AutenticacaoFalsa fake) {
  return ProviderScope(
    overrides: [
      autenticacaoRepositoryProvider.overrideWithValue(fake),
      apiSaudeProvider.overrideWith((ref) async => true),
    ],
    child: const OficinaFacilApp(),
  );
}

/// Tela de celular (estreita): o menu aparece embaixo. O padrão do teste (800 px) é "tela larga".
void _celular(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> _preencherEEntrar(
  WidgetTester tester, {
  String email = 'ana@teste.local',
  String senha = 'senha-forte-1',
}) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), email);
  await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), senha);
  await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
  await tester.pumpAndSettle();
}

void main() {
  group('T01 Login', () {
    testWidgets('sem sessão o app abre no login', (tester) async {
      await tester.pumpWidget(_app(AutenticacaoFalsa()));
      await tester.pumpAndSettle();

      expect(find.text('Entrar'), findsWidgets);
      expect(find.widgetWithText(TextFormField, 'E-mail'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Senha'), findsOneWidget);
    });

    testWidgets('campos vazios mostram o que falta e não chamam o servidor', (
      tester,
    ) async {
      final fake = AutenticacaoFalsa();
      await tester.pumpWidget(_app(fake));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Informe o e-mail'), findsOneWidget);
      expect(find.text('Informe a senha'), findsOneWidget);
    });

    testWidgets('e-mail sem @ é recusado antes de chamar o servidor', (
      tester,
    ) async {
      await tester.pumpWidget(_app(AutenticacaoFalsa()));
      await tester.pumpAndSettle();

      await _preencherEEntrar(tester, email: 'sem-arroba');

      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('credencial errada mostra mensagem genérica', (tester) async {
      final fake = AutenticacaoFalsa()
        ..falhaAoEntrar = const CredenciaisInvalidas();
      await tester.pumpWidget(_app(fake));
      await tester.pumpAndSettle();

      await _preencherEEntrar(tester);

      expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
      expect(find.text('Olá, Ana Atendente'), findsNothing);
    });

    testWidgets('usuário desativado mostra aviso próprio', (tester) async {
      final fake = AutenticacaoFalsa()
        ..falhaAoEntrar = const UsuarioDesativado();
      await tester.pumpWidget(_app(fake));
      await tester.pumpAndSettle();

      await _preencherEEntrar(tester);

      expect(
        find.text('Este usuário está desativado. Procure o gerente.'),
        findsOneWidget,
      );
    });

    testWidgets('usuário sem perfil mostra aviso próprio', (tester) async {
      final fake = AutenticacaoFalsa()
        ..falhaAoEntrar = const UsuarioSemPerfil();
      await tester.pumpWidget(_app(fake));
      await tester.pumpAndSettle();

      await _preencherEEntrar(tester);

      expect(
        find.text('Este usuário não tem perfil cadastrado. Procure o gerente.'),
        findsOneWidget,
      );
    });

    testWidgets('sem rede mostra mensagem de conexão', (tester) async {
      final fake = AutenticacaoFalsa()
        ..falhaAoEntrar = const SemConexaoException();
      await tester.pumpWidget(_app(fake));
      await tester.pumpAndSettle();

      await _preencherEEntrar(tester);

      expect(find.textContaining('Sem conexão com o servidor'), findsOneWidget);
    });

    testWidgets('a senha começa oculta e o botão alterna a visibilidade', (
      tester,
    ) async {
      await tester.pumpWidget(_app(AutenticacaoFalsa()));
      await tester.pumpAndSettle();

      EditableText campo() => tester.widget<EditableText>(
        find.descendant(
          of: find.widgetWithText(TextFormField, 'Senha'),
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
      await tester.pumpWidget(_app(fake));
      await tester.pumpAndSettle();

      await _preencherEEntrar(tester);

      expect(find.text('Olá, Ana Atendente'), findsOneWidget);
      expect(find.text('Atendente'), findsWidgets);
    });
  });

  group('sessão guardada', () {
    testWidgets('abre direto no início, sem passar pelo login', (tester) async {
      await tester.pumpWidget(
        _app(AutenticacaoFalsa(sessaoInicial: usuarioGerente)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Olá, Gerente Um'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'E-mail'), findsNothing);
    });

    testWidgets('sem rede ao abrir, oferece tentar de novo e depois entra', (
      tester,
    ) async {
      final fake = AutenticacaoFalsa(sessaoInicial: usuarioGerente)
        ..falhaAoCarregar = const SemConexaoException();
      await tester.pumpWidget(_app(fake));
      await tester.pumpAndSettle();

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
      _celular(tester);
      await tester.pumpWidget(
        _app(AutenticacaoFalsa(sessaoInicial: usuarioGerente)),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ActionChip, 'Usuários'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('o atendente não vê Usuários nem menu inferior', (
      tester,
    ) async {
      _celular(tester);
      await tester.pumpWidget(
        _app(AutenticacaoFalsa(sessaoInicial: usuarioAtendente)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Usuários'), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
      expect(
        find.text('As funções do seu perfil chegam nas próximas semanas.'),
        findsOneWidget,
      );
    });

    testWidgets('mostra se o servidor está conectado', (tester) async {
      await tester.pumpWidget(
        _app(AutenticacaoFalsa(sessaoInicial: usuarioAtendente)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Servidor conectado'), findsOneWidget);
    });

    testWidgets('Sair encerra a sessão e volta ao login', (tester) async {
      final fake = AutenticacaoFalsa(sessaoInicial: usuarioAtendente);
      await tester.pumpWidget(_app(fake));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Conta'));
      await tester.pumpAndSettle();
      expect(find.text('Ana Atendente · Atendente'), findsOneWidget);
      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();

      expect(fake.saidas, 1);
      expect(find.widgetWithText(TextFormField, 'E-mail'), findsOneWidget);
    });

    testWidgets('em tela larga o menu vira barra lateral', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _app(AutenticacaoFalsa(sessaoInicial: usuarioGerente)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('abre em português do Brasil', (tester) async {
      await tester.pumpWidget(_app(AutenticacaoFalsa()));
      await tester.pumpAndSettle();

      final contexto = tester.element(find.byType(Scaffold));
      expect(Localizations.localeOf(contexto), const Locale('pt', 'BR'));
      expect(MaterialLocalizations.of(contexto).cancelButtonLabel, 'Cancelar');
    });
  });
}
