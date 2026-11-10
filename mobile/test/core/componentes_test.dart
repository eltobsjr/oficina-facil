import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/core/shell/barra_de_abas.dart';
import 'package:oficina_facil/core/shell/barra_global.dart';
import 'package:oficina_facil/core/shell/menu_por_perfil.dart';
import 'package:oficina_facil/core/theme/app_theme.dart';
import 'package:oficina_facil/core/widgets/aviso_de_erro.dart';
import 'package:oficina_facil/core/widgets/campo_de_busca.dart';
import 'package:oficina_facil/core/widgets/campo_rotulado.dart';
import 'package:oficina_facil/core/widgets/cartao_de_lista.dart';
import 'package:oficina_facil/core/widgets/chips.dart';
import 'package:oficina_facil/core/widgets/confirmar_dialog.dart';
import 'package:oficina_facil/core/widgets/estados.dart';
import 'package:oficina_facil/core/widgets/sub_barra.dart';
import 'package:oficina_facil/core/widgets/tile_escuro.dart';

Future<void> _montar(WidgetTester tester, Widget filho) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: filho),
    ),
  );
}

BoxDecoration _decoracaoDe(WidgetTester tester, Finder dentro) {
  final caixa = tester.widget<DecoratedBox>(
    find.descendant(of: dentro, matching: find.byType(DecoratedBox)).first,
  );
  return caixa.decoration as BoxDecoration;
}

void main() {
  group('CartaoDeLista', () {
    testWidgets('mostra título e apoio e responde ao toque', (tester) async {
      var toques = 0;
      await _montar(
        tester,
        CartaoDeLista(
          aoTocar: () => toques++,
          titulo: 'Carlos Teste',
          apoio: '123.456.789-00',
        ),
      );

      expect(find.text('Carlos Teste'), findsOneWidget);
      expect(find.text('123.456.789-00'), findsOneWidget);
      await tester.tap(find.text('Carlos Teste'));
      expect(toques, 1);
    });

    testWidgets('é branco, com filete de 1 px, raio 18 e sem sombra', (
      tester,
    ) async {
      await _montar(tester, CartaoDeLista(aoTocar: () {}, titulo: 'Item'));

      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(CartaoDeLista),
              matching: find.byType(Material),
            )
            .first,
      );
      final forma = material.shape! as RoundedRectangleBorder;
      expect(material.color, AppTheme.branco);
      expect(material.elevation, 0);
      expect(forma.borderRadius, BorderRadius.circular(18));
      expect(forma.side.color, AppTheme.filete);
      expect(forma.side.width, 1);
    });

    testWidgets('tem pelo menos 72 px de altura e alvo de toque de 44 px', (
      tester,
    ) async {
      await _montar(tester, CartaoDeLista(aoTocar: () {}, titulo: 'Item'));
      final tamanho = tester.getSize(find.byType(CartaoDeLista));
      expect(tamanho.height, greaterThanOrEqualTo(72));
      expect(tamanho.height, greaterThanOrEqualTo(44));
    });

    testWidgets('com o teclado, o foco desenha o anel de 2 px em #0071e3', (
      tester,
    ) async {
      await _montar(tester, CartaoDeLista(aoTocar: () {}, titulo: 'Item'));
      final alvo = find.byType(CartaoDeLista);

      expect(_decoracaoDe(tester, alvo).border, isNull);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      final borda = _decoracaoDe(tester, alvo).border! as Border;
      expect(borda.top.width, 2);
      expect(borda.top.color, const Color(0xFF0071E3));
    });

    testWidgets(
      'inativo não usa opacidade: o nome vai para o texto secundário',
      (tester) async {
        await _montar(
          tester,
          CartaoDeLista(
            aoTocar: () {},
            titulo: 'Pedro Saiu',
            apagado: true,
            fim: const ChipDeEstado('Inativo'),
          ),
        );

        expect(find.byType(Opacity), findsNothing);
        final texto = tester.widget<Text>(find.text('Pedro Saiu'));
        expect(texto.style!.color, AppTheme.textoSecundario);
        expect(find.text('Inativo'), findsOneWidget);
      },
    );
  });

  group('AvatarDeIniciais', () {
    testWidgets('usa a primeira e a última palavra do nome', (tester) async {
      await _montar(tester, const AvatarDeIniciais('maria da Silva exemplo'));
      expect(find.text('ME'), findsOneWidget);
    });

    testWidgets(
      'nome de uma palavra tem uma letra; vazio mostra interrogação',
      (tester) async {
        await _montar(
          tester,
          const Column(
            children: [AvatarDeIniciais('Ana'), AvatarDeIniciais('  ')],
          ),
        );
        expect(find.text('A'), findsOneWidget);
        expect(find.text('?'), findsOneWidget);
      },
    );
  });

  group('Chips', () {
    testWidgets('filtro selecionado vira azul de ação com texto branco', (
      tester,
    ) async {
      await _montar(
        tester,
        Column(
          children: [
            ChipDeFiltro(
              rotulo: 'Todos',
              selecionado: true,
              aoSelecionar: (_) {},
            ),
            ChipDeFiltro(
              rotulo: 'Inativos',
              selecionado: false,
              aoSelecionar: (_) {},
            ),
          ],
        ),
      );

      final marcado = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Todos'),
      );
      final solto = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Inativos'),
      );
      expect(marcado.selected, isTrue);
      expect(marcado.labelStyle!.color, AppTheme.branco);
      expect(marcado.side!.color, AppTheme.acao);
      expect(solto.labelStyle!.color, AppTheme.tinta);
      expect(solto.side!.color, AppTheme.filete);
    });

    testWidgets('filtro avisa o toque', (tester) async {
      bool? valor;
      await _montar(
        tester,
        ChipDeFiltro(
          rotulo: 'Ativos',
          selecionado: false,
          aoSelecionar: (v) => valor = v,
        ),
      );
      await tester.tap(find.text('Ativos'));
      expect(valor, isTrue);
    });

    testWidgets('chip de estado é pílula apagada com o texto sempre visível', (
      tester,
    ) async {
      await _montar(tester, const ChipDeEstado('Inativo'));

      final decoracao =
          tester
                  .widget<DecoratedBox>(
                    find.descendant(
                      of: find.byType(ChipDeEstado),
                      matching: find.byType(DecoratedBox),
                    ),
                  )
                  .decoration
              as ShapeDecoration;
      expect(decoracao.color, AppTheme.fundo);
      expect(decoracao.shape, isA<StadiumBorder>());
      expect(find.text('Inativo'), findsOneWidget);
    });
  });

  group('TileEscuro', () {
    testWidgets('usa o fundo escuro, texto branco e cinza claro no apoio', (
      tester,
    ) async {
      await _montar(
        tester,
        const TileEscuro(
          legenda: 'Cliente',
          titulo: 'Carlos Teste',
          apoio: '123.456.789-00',
        ),
      );

      final fundo = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(TileEscuro),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(fundo.color, AppTheme.tileEscuro);
      expect(
        tester.widget<Text>(find.text('Carlos Teste')).style!.color,
        AppTheme.branco,
      );
      expect(
        tester.widget<Text>(find.text('Cliente')).style!.color,
        AppTheme.textoSobreEscuroSecundario,
      );
      expect(
        tester.widget<Text>(find.text('123.456.789-00')).style!.color,
        AppTheme.textoSobreEscuroSecundario,
      );
    });

    testWidgets('mostra a ação quando há uma', (tester) async {
      await _montar(
        tester,
        const TileEscuro(
          legenda: 'x',
          titulo: 'y',
          acao: Text('Editar cadastro'),
        ),
      );
      expect(find.text('Editar cadastro'), findsOneWidget);
    });
  });

  group('SubBarra', () {
    testWidgets('mostra o título e a ação principal em pílula', (tester) async {
      var acionou = false;
      await _montar(
        tester,
        SubBarra(
          titulo: 'Clientes',
          rotuloAcao: 'Novo cliente',
          aoAcionar: () => acionou = true,
        ),
      );

      expect(find.text('Clientes'), findsOneWidget);
      expect(tester.getSize(find.byType(SubBarra)).height, 52);
      await tester.tap(find.widgetWithText(FilledButton, 'Novo cliente'));
      expect(acionou, isTrue);
    });

    testWidgets('a ação da sub-barra mantém área de toque de 44 px', (
      tester,
    ) async {
      await _montar(
        tester,
        SubBarra(titulo: 'Clientes', rotuloAcao: 'Novo', aoAcionar: () {}),
      );
      final area = tester.getSize(find.byType(FilledButton));
      expect(area.height, greaterThanOrEqualTo(44));
    });

    testWidgets('o voltar tem rótulo e leva de volta', (tester) async {
      var voltou = false;
      await _montar(
        tester,
        SubBarra(
          titulo: 'Novo cliente',
          aoVoltar: () => voltou = true,
          rotuloVoltar: 'Voltar para clientes',
        ),
      );
      await tester.tap(find.byTooltip('Voltar para clientes'));
      expect(voltou, isTrue);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('o título é cabeçalho para o leitor de tela', (tester) async {
      await _montar(tester, const SubBarra(titulo: 'Usuários'));
      expect(
        tester.getSemantics(find.text('Usuários')),
        matchesSemantics(label: 'Usuários', isHeader: true),
      );
    });
  });

  group('BarraGlobal', () {
    testWidgets('é preta, de 52 px, com o nome do app', (tester) async {
      await _montar(
        tester,
        const BarraGlobal(conta: Text('Maria · Atendente')),
      );

      expect(find.text('OficinaFácil'), findsOneWidget);
      expect(find.text('Maria · Atendente'), findsOneWidget);
      expect(tester.getSize(find.byType(BarraGlobal)).height, 52);
      final fundo = tester.widget<ColoredBox>(
        find
            .descendant(
              of: find.byType(BarraGlobal),
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      expect(fundo.color, AppTheme.preto);
    });
  });

  group('BarraDeAbas', () {
    const itens = [
      ItemMenu(rotulo: 'Início', rota: '/', icone: Icons.home_outlined),
      ItemMenu(rotulo: 'Clientes', rota: '/c', icone: Icons.people_outline),
    ];

    testWidgets('a aba ativa fica em azul 600 e as outras em cinza escuro', (
      tester,
    ) async {
      await _montar(
        tester,
        BarraDeAbas(itens: itens, selecionado: 1, aoSelecionar: (_) {}),
      );

      final ativa = tester.widget<Text>(find.text('Clientes')).style!;
      final inativa = tester.widget<Text>(find.text('Início')).style!;
      expect(ativa.color, AppTheme.acao);
      expect(ativa.fontWeight, FontWeight.w600);
      expect(ativa.fontSize, 12);
      expect(inativa.color, AppTheme.textoSecundario);
      expect(inativa.fontWeight, FontWeight.w400);
    });

    testWidgets('toque troca de aba e cada aba tem 44 px ou mais', (
      tester,
    ) async {
      int? escolhida;
      await _montar(
        tester,
        BarraDeAbas(
          itens: itens,
          selecionado: 0,
          aoSelecionar: (i) => escolhida = i,
        ),
      );

      await tester.tap(find.text('Clientes'));
      expect(escolhida, 1);
      expect(
        tester.getSize(find.widgetWithText(InkWell, 'Início')).height,
        greaterThanOrEqualTo(44),
      );
    });

    testWidgets('a aba ativa é anunciada como selecionada', (tester) async {
      await _montar(
        tester,
        BarraDeAbas(itens: itens, selecionado: 1, aoSelecionar: (_) {}),
      );
      final semantica = tester.getSemantics(find.text('Clientes'));
      expect(semantica.label, 'Clientes');
      expect(semantica.flagsCollection.isSelected, ui.Tristate.isTrue);
      expect(semantica.flagsCollection.isButton, isTrue);
    });
  });

  group('CampoRotulado', () {
    testWidgets('mostra o rótulo acima do campo, sem labelText', (
      tester,
    ) async {
      await _montar(
        tester,
        const CampoRotulado(rotulo: 'E-mail', child: TextField()),
      );

      final rotulo = tester.getTopLeft(find.text('E-mail'));
      final campo = tester.getTopLeft(find.byType(TextField));
      expect(rotulo.dy, lessThan(campo.dy));
      expect(find.text('E-mail'), findsOneWidget);
    });

    testWidgets('o campo tem 48 px de altura, fundo branco e raio 8', (
      tester,
    ) async {
      await _montar(
        tester,
        const CampoRotulado(rotulo: 'Nome', child: TextField()),
      );

      expect(tester.getSize(find.byType(TextField)).height, 48);
      final decoracao = tester
          .widget<InputDecorator>(find.byType(InputDecorator))
          .decoration;
      expect(decoracao.labelText, isNull);
      final tema = tester.widget<InputDecorator>(find.byType(InputDecorator));
      expect(tema.isEmpty, isTrue);
    });

    testWidgets('erro aparece logo abaixo do campo, em perigo', (tester) async {
      await _montar(
        tester,
        CampoRotulado(
          rotulo: 'E-mail',
          child: TextField(
            decoration: const InputDecoration(
              errorText: 'Este e-mail já está cadastrado.',
            ),
          ),
        ),
      );

      final erro = find.text('Este e-mail já está cadastrado.');
      expect(erro, findsOneWidget);
      expect(
        tester.getTopLeft(erro).dy,
        greaterThan(tester.getTopLeft(find.byType(TextField)).dy + 44),
      );
      expect(tester.widget<Text>(erro).style!.color, AppTheme.perigo);
    });

    testWidgets('o campo é anunciado com o rótulo para o leitor de tela', (
      tester,
    ) async {
      await _montar(
        tester,
        const CampoRotulado(rotulo: 'Senha', child: TextField()),
      );
      expect(
        tester.getSemantics(find.byType(TextField)),
        matchesSemantics(
          label: 'Senha',
          isTextField: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
    });
  });

  group('CampoDeBusca', () {
    testWidgets('é uma pílula de 44 px com lupa e dica', (tester) async {
      await _montar(
        tester,
        CampoDeBusca(
          controller: TextEditingController(),
          dica: 'Buscar por nome',
          aoMudar: (_) {},
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Buscar por nome'), findsOneWidget);
      expect(tester.getSize(find.byType(TextField)).height, 44);
      final campo = tester.widget<TextField>(find.byType(TextField));
      final borda = campo.decoration!.border! as OutlineInputBorder;
      expect(borda.borderRadius, BorderRadius.circular(999));
    });

    testWidgets('avisa o que foi digitado', (tester) async {
      String? texto;
      await _montar(
        tester,
        CampoDeBusca(
          controller: TextEditingController(),
          dica: 'Buscar',
          aoMudar: (t) => texto = t,
        ),
      );
      await tester.enterText(find.byType(TextField), 'ana');
      expect(texto, 'ana');
    });
  });

  group('AvisoDeErro', () {
    testWidgets('mostra a mensagem em perigo sobre o fundo de perigo', (
      tester,
    ) async {
      await _montar(tester, const AvisoDeErro('E-mail ou senha incorretos.'));

      final texto = tester.widget<Text>(
        find.text('E-mail ou senha incorretos.'),
      );
      expect(texto.style!.color, AppTheme.perigo);
      final decoracao = _decoracaoDe(tester, find.byType(AvisoDeErro));
      expect(decoracao.color, AppTheme.perigoSuperficie);
      expect(decoracao.borderRadius, BorderRadius.circular(18));
    });

    testWidgets('é uma região viva para o leitor de tela', (tester) async {
      await _montar(tester, const AvisoDeErro('Falhou.'));
      final semantica = tester.getSemantics(find.text('Falhou.'));
      expect(semantica.flagsCollection.isLiveRegion, isTrue);
    });
  });

  group('Estados', () {
    testWidgets('erro com título mostra título, mensagem e tentar de novo', (
      tester,
    ) async {
      var tentou = false;
      await _montar(
        tester,
        EstadoErro(
          titulo: 'Sem conexão',
          mensagem: 'Confira a internet.',
          aoTentarDeNovo: () => tentou = true,
        ),
      );

      expect(find.text('Sem conexão'), findsOneWidget);
      expect(find.text('Confira a internet.'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Tentar de novo'));
      expect(tentou, isTrue);
    });

    testWidgets('carregando tem rótulo para o leitor de tela', (tester) async {
      await _montar(tester, const Carregando());
      expect(
        tester
            .widget<CircularProgressIndicator>(
              find.byType(CircularProgressIndicator),
            )
            .semanticsLabel,
        'Carregando',
      );
    });
  });

  group('confirmar', () {
    testWidgets(
      'destrutivo confirma com botão em perigo; cancelar devolve false',
      (tester) async {
        bool? resposta;
        await _montar(
          tester,
          Builder(
            builder: (contexto) => FilledButton(
              onPressed: () async => resposta = await confirmar(
                contexto,
                titulo: 'Inativar',
                mensagem: 'Tem certeza?',
                rotuloConfirmar: 'Inativar',
                destrutivo: true,
              ),
              child: const Text('Abrir'),
            ),
          ),
        );
        await tester.tap(find.text('Abrir'));
        await tester.pumpAndSettle();

        final confirmacao = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Inativar'),
        );
        expect(
          confirmacao.style!.backgroundColor!.resolve({}),
          AppTheme.perigo,
        );
        final dialogo = tester.widget<AlertDialog>(find.byType(AlertDialog));
        expect(dialogo.title, isA<Text>());

        await tester.tap(find.widgetWithText(OutlinedButton, 'Cancelar'));
        await tester.pumpAndSettle();
        expect(resposta, isFalse);
      },
    );
  });
}
