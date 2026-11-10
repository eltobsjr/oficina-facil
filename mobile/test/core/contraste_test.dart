import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/core/theme/app_theme.dart';

double _luminancia(Color cor) {
  double canal(double valor) => valor <= 0.03928
      ? valor / 12.92
      : pow((valor + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * canal(cor.r) + 0.7152 * canal(cor.g) + 0.0722 * canal(cor.b);
}

double _razao(Color a, Color b) {
  final claro = max(_luminancia(a), _luminancia(b));
  final escuro = min(_luminancia(a), _luminancia(b));
  return (claro + 0.05) / (escuro + 0.05);
}

void main() {
  const minimoAA = 4.5;

  final pares = <String, (Color, Color)>{
    'branco sobre o azul de ação': (AppTheme.branco, AppTheme.acao),
    'azul de ação sobre branco': (AppTheme.acao, AppTheme.branco),
    'azul de ação sobre parchment': (AppTheme.acao, AppTheme.fundo),
    'tinta sobre parchment': (AppTheme.tinta, AppTheme.fundo),
    'tinta sobre branco': (AppTheme.tinta, AppTheme.branco),
    'texto secundário sobre parchment': (
      AppTheme.textoSecundario,
      AppTheme.fundo,
    ),
    'texto secundário sobre branco': (
      AppTheme.textoSecundario,
      AppTheme.branco,
    ),
    'branco sobre o tile escuro': (AppTheme.branco, AppTheme.tileEscuro),
    'cinza claro sobre o tile escuro': (
      AppTheme.textoSobreEscuroSecundario,
      AppTheme.tileEscuro,
    ),
    'azul sobre escuro no tile escuro': (
      AppTheme.acaoSobreEscuro,
      AppTheme.tileEscuro,
    ),
    'branco sobre a barra global': (AppTheme.branco, AppTheme.preto),
    'perigo sobre a superfície de perigo': (
      AppTheme.perigo,
      AppTheme.perigoSuperficie,
    ),
    'perigo sobre branco': (AppTheme.perigo, AppTheme.branco),
    'branco sobre perigo': (AppTheme.branco, AppTheme.perigo),
  };

  for (final MapEntry(:key, :value) in pares.entries) {
    test('contraste AA (4,5:1): $key', () {
      expect(_razao(value.$1, value.$2), greaterThanOrEqualTo(minimoAA));
    });
  }

  test(
    'o cinza de desabilitado não passa AA e por isso não serve para leitura',
    () {
      expect(
        _razao(AppTheme.textoDesabilitado, AppTheme.fundo),
        lessThan(minimoAA),
      );
    },
  );

  test('a razão calculada confere com valores conhecidos', () {
    expect(_razao(AppTheme.branco, AppTheme.preto), closeTo(21, 0.01));
    expect(_razao(AppTheme.branco, AppTheme.branco), closeTo(1, 0.001));
  });
}
