import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/app.dart';
import 'package:oficina_facil/core/theme/app_theme.dart';
import 'package:oficina_facil/features/autenticacao/presentation/providers/sessao_provider.dart';

import '../helpers/autenticacao_falsa.dart';

void main() {
  final tema = AppTheme.light;

  test('a cor de ação é a única cor interativa do esquema', () {
    final esquema = tema.colorScheme;
    expect(esquema.primary, const Color(0xFF0066CC));
    expect(esquema.secondary, esquema.primary);
    expect(esquema.tertiary, esquema.primary);
    expect(esquema.onPrimary, const Color(0xFFFFFFFF));
  });

  test('a cor da marca continua só para o logo e o ícone', () {
    expect(AppTheme.marca, const Color(0xFF1F4E79));
    expect(tema.colorScheme.primary, isNot(AppTheme.marca));
  });

  test('fundo das telas é parchment e o tema é só claro', () {
    expect(tema.brightness, Brightness.light);
    expect(tema.scaffoldBackgroundColor, const Color(0xFFF5F5F7));
    expect(tema.colorScheme.surface, const Color(0xFFFFFFFF));
  });

  test('botões são pílulas de 44 px de altura mínima', () {
    for (final estilo in [
      tema.filledButtonTheme.style!,
      tema.outlinedButtonTheme.style!,
      tema.textButtonTheme.style!,
    ]) {
      expect(estilo.shape!.resolve({}), isA<StadiumBorder>());
      expect(estilo.minimumSize!.resolve({})!.height, 44);
    }
  });

  test(
    'botão principal é azul com texto branco e, desabilitado, parchment',
    () {
      final estilo = tema.filledButtonTheme.style!;
      expect(estilo.backgroundColor!.resolve({}), AppTheme.acao);
      expect(estilo.foregroundColor!.resolve({}), AppTheme.branco);
      expect(
        estilo.backgroundColor!.resolve({WidgetState.disabled}),
        AppTheme.fundo,
      );
      expect(
        estilo.foregroundColor!.resolve({WidgetState.disabled}),
        AppTheme.textoDesabilitado,
      );
      expect(
        estilo.side!.resolve({WidgetState.disabled})!.color,
        AppTheme.filete,
      );
    },
  );

  test('o foco do teclado desenha contorno de 2 px em #0071e3', () {
    for (final estilo in [
      tema.filledButtonTheme.style!,
      tema.outlinedButtonTheme.style!,
      tema.textButtonTheme.style!,
    ]) {
      final lado = estilo.side!.resolve({WidgetState.focused})!;
      expect(lado.width, 2);
      expect(lado.color, const Color(0xFF0071E3));
    }
  });

  test('botão destrutivo usa perigo no texto e no filete', () {
    final estilo = AppTheme.estiloDestrutivo;
    expect(estilo.foregroundColor!.resolve({}), AppTheme.perigo);
    expect(estilo.side!.resolve({})!.color, AppTheme.perigo);
    expect(estilo.shape!.resolve({}), isA<StadiumBorder>());
  });

  test('campos têm fundo branco, filete e raio 8; erro em perigo', () {
    final campos = tema.inputDecorationTheme;
    final borda = campos.enabledBorder! as OutlineInputBorder;
    expect(borda.borderRadius, BorderRadius.circular(8));
    expect(borda.borderSide.color, AppTheme.filete);
    expect(borda.borderSide.width, 1);
    expect(campos.fillColor, isNotNull);
    expect(campos.constraints!.minHeight, 48);
    final erro = campos.errorBorder! as OutlineInputBorder;
    expect(erro.borderSide.color, AppTheme.perigo);
    final foco = campos.focusedBorder! as OutlineInputBorder;
    expect(foco.borderSide.color, AppTheme.acaoFoco);
    expect(foco.borderSide.width, 2);
  });

  test('cartão é branco, com filete, raio 18 e sem sombra', () {
    final cartao = tema.cardTheme;
    expect(cartao.color, AppTheme.branco);
    expect(cartao.elevation, 0);
    final forma = cartao.shape! as RoundedRectangleBorder;
    expect(forma.borderRadius, BorderRadius.circular(18));
    expect(forma.side.color, AppTheme.filete);
  });

  test('chip e diálogo seguem a pílula e o raio 18', () {
    expect(tema.chipTheme.shape, isA<StadiumBorder>());
    expect(tema.chipTheme.selectedColor, AppTheme.acao);
    final dialogo = tema.dialogTheme.shape! as RoundedRectangleBorder;
    expect(dialogo.borderRadius, BorderRadius.circular(18));
    expect(tema.dialogTheme.elevation, 0);
  });

  test(
    'texto: corpo de 17 px, legenda de 14 px, miúdo de 12 px, sem peso 500',
    () {
      final textos = tema.textTheme;
      expect(textos.bodyLarge!.fontSize, 17);
      expect(textos.bodyLarge!.letterSpacing, -0.374);
      expect(textos.bodySmall!.fontSize, 14);
      expect(textos.bodySmall!.letterSpacing, -0.224);
      expect(textos.labelSmall!.fontSize, 12);
      expect(textos.headlineSmall!.fontWeight, FontWeight.w600);
      for (final estilo in [
        textos.displayLarge,
        textos.displayMedium,
        textos.displaySmall,
        textos.headlineLarge,
        textos.headlineMedium,
        textos.headlineSmall,
        textos.titleLarge,
        textos.titleMedium,
        textos.titleSmall,
        textos.bodyLarge,
        textos.bodyMedium,
        textos.bodySmall,
        textos.labelLarge,
        textos.labelMedium,
        textos.labelSmall,
      ]) {
        expect(estilo!.fontWeight, isNot(FontWeight.w500));
      }
    },
  );

  test(
    'texto secundário é #333333 e o cinza de desabilitado não é usado como leitura',
    () {
      expect(tema.textTheme.bodySmall!.color, const Color(0xFF333333));
      expect(tema.colorScheme.onSurfaceVariant, const Color(0xFF333333));
    },
  );

  testWidgets('MaterialApp do app só tem o tema claro', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          autenticacaoRepositoryProvider.overrideWithValue(AutenticacaoFalsa()),
        ],
        child: const OficinaFacilApp(),
      ),
    );
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme, AppTheme.light);
    expect(app.darkTheme, isNull);
  });
}
