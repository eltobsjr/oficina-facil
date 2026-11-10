import 'package:flutter/material.dart';

/// Design system "OficinaFácil" (decisão 013): interface quieta, ação em azul único.
/// Todas as cores e raios da interface existem só aqui; as telas usam o tema ou estas constantes.
abstract final class AppTheme {
  /// Cor da marca: só o logo e o ícone do app. Não é cor de interface.
  static const marca = Color(0xFF1F4E79);

  /// Única cor interativa: botões em pílula, links, abas ativas.
  static const acao = Color(0xFF0066CC);
  static const acaoFoco = Color(0xFF0071E3);
  static const acaoSobreEscuro = Color(0xFF2997FF);

  static const branco = Color(0xFFFFFFFF);
  static const preto = Color(0xFF000000);
  static const fundo = Color(0xFFF5F5F7);
  static const tileEscuro = Color(0xFF272729);

  static const tinta = Color(0xFF1D1D1F);
  static const textoSecundario = Color(0xFF333333);
  static const textoSobreEscuroSecundario = Color(0xFFCCCCCC);

  /// Só para texto desabilitado: não passa AA como texto de leitura.
  static const textoDesabilitado = Color(0xFF7A7A7A);

  static const filete = Color(0xFFE0E0E0);

  static const perigo = Color(0xFFB3261E);
  static const perigoSuperficie = Color(0xFFFDECEA);

  static const raioCampo = 8.0;
  static const raioCartao = 18.0;

  /// Espaço vertical entre campos de um formulário.
  static const espacoEntreCampos = 14.0;

  /// Margem do conteúdo das telas de formulário.
  static const margemDoFormulario = EdgeInsets.fromLTRB(20, 20, 20, 24);

  /// Margem das listas rolantes de clientes e usuários.
  static const margemDaLista = EdgeInsets.fromLTRB(20, 0, 20, 24);

  /// Parchment a 80%: fundo das barras foscas.
  static final fundoFosco = fundo.withValues(alpha: 0.8);

  static const _pilula = StadiumBorder();

  static const _escala = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w600,
      height: 1.15,
      letterSpacing: -0.374,
      color: tinta,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.14,
      letterSpacing: 0.196,
      color: tinta,
    ),
    headlineSmall: TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.w600,
      height: 1.19,
      letterSpacing: 0.231,
      color: tinta,
    ),
    titleLarge: TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.w600,
      height: 1.19,
      letterSpacing: 0.231,
      color: tinta,
    ),
    titleMedium: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.24,
      letterSpacing: -0.374,
      color: tinta,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.29,
      letterSpacing: -0.224,
      color: tinta,
    ),
    bodyLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      height: 1.47,
      letterSpacing: -0.374,
      color: tinta,
    ),
    bodyMedium: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      height: 1.47,
      letterSpacing: -0.374,
      color: tinta,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.43,
      letterSpacing: -0.224,
      color: textoSecundario,
    ),
    labelLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      height: 1,
      letterSpacing: -0.374,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.29,
      letterSpacing: -0.224,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.3,
      letterSpacing: -0.12,
    ),
  );

  static const _esquema = ColorScheme(
    brightness: Brightness.light,
    primary: acao,
    onPrimary: branco,
    primaryContainer: fundo,
    onPrimaryContainer: tinta,
    secondary: acao,
    onSecondary: branco,
    secondaryContainer: fundo,
    onSecondaryContainer: tinta,
    tertiary: acao,
    onTertiary: branco,
    tertiaryContainer: fundo,
    onTertiaryContainer: tinta,
    error: perigo,
    onError: branco,
    errorContainer: perigoSuperficie,
    onErrorContainer: perigo,
    surface: branco,
    onSurface: tinta,
    onSurfaceVariant: textoSecundario,
    outline: filete,
    outlineVariant: filete,
    shadow: preto,
    scrim: preto,
    inverseSurface: tinta,
    onInverseSurface: branco,
    inversePrimary: acaoSobreEscuro,
    surfaceTint: Colors.transparent,
    surfaceContainerLowest: branco,
    surfaceContainerLow: fundo,
    surfaceContainer: fundo,
    surfaceContainerHigh: branco,
    surfaceContainerHighest: fundo,
  );

  /// Tema único do app (só claro: o design system não define tema escuro).
  static final ThemeData light = _construir();

  /// Anel de foco do teclado: contorno de 2 px.
  static const _anelDeFoco = BorderSide(color: acaoFoco, width: 2);

  static WidgetStateProperty<BorderSide?> _contorno(Color cor) {
    return WidgetStateProperty.resolveWith((estados) {
      if (estados.contains(WidgetState.disabled)) {
        return const BorderSide(color: filete);
      }
      if (estados.contains(WidgetState.focused)) return _anelDeFoco;
      return BorderSide(color: cor);
    });
  }

  /// Pílula de 44 px sem sombra, comum ao botão preenchido e aos de contorno.
  /// A repetição dos valores nos dois estilos é intencional do design system.
  static ButtonStyle get _estiloBase => ButtonStyle(
    minimumSize: const WidgetStatePropertyAll(Size(64, 44)),
    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 22)),
    shape: const WidgetStatePropertyAll(_pilula),
    elevation: const WidgetStatePropertyAll(0),
    textStyle: WidgetStatePropertyAll(_escala.labelLarge),
  );

  static ButtonStyle _estiloContorno(Color cor) {
    return _estiloBase.copyWith(
      backgroundColor: WidgetStateProperty.resolveWith(
        (estados) =>
            estados.contains(WidgetState.disabled) ? fundo : Colors.transparent,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (estados) =>
            estados.contains(WidgetState.disabled) ? textoDesabilitado : cor,
      ),
      side: _contorno(cor),
    );
  }

  /// Botão secundário em pílula com texto e filete de perigo (cancelar, inativar).
  static ButtonStyle get estiloDestrutivo => _estiloContorno(perigo);

  /// Botão de ação da sub-barra: mesma pílula azul, mais baixa. A área de toque segue em 44.
  static ButtonStyle get estiloAcaoDaSubBarra => FilledButton.styleFrom(
    minimumSize: const Size(64, 34),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    textStyle: _escala.labelMedium,
  );

  static ThemeData _construir() {
    final campoBorda = OutlineInputBorder(
      borderRadius: BorderRadius.circular(raioCampo),
      borderSide: const BorderSide(color: filete),
    );
    OutlineInputBorder campoBordaDe(Color cor) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(raioCampo),
      borderSide: BorderSide(color: cor, width: 2),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: _esquema,
      scaffoldBackgroundColor: fundo,
      canvasColor: branco,
      dividerColor: filete,
      focusColor: acaoFoco.withValues(alpha: 0.3),
      textTheme: _escala,
      iconTheme: const IconThemeData(color: tinta, size: 22),
      filledButtonTheme: FilledButtonThemeData(
        style: _estiloBase.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith(
            (estados) => estados.contains(WidgetState.disabled) ? fundo : acao,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (estados) => estados.contains(WidgetState.disabled)
                ? textoDesabilitado
                : branco,
          ),
          side: WidgetStateProperty.resolveWith((estados) {
            if (estados.contains(WidgetState.disabled)) {
              return const BorderSide(color: filete);
            }
            if (estados.contains(WidgetState.focused)) return _anelDeFoco;
            return null;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _estiloContorno(acao),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16),
          ),
          shape: const WidgetStatePropertyAll(_pilula),
          textStyle: WidgetStatePropertyAll(_escala.labelLarge),
          foregroundColor: WidgetStateProperty.resolveWith(
            (estados) => estados.contains(WidgetState.disabled)
                ? textoDesabilitado
                : acao,
          ),
          side: WidgetStateProperty.resolveWith(
            (estados) =>
                estados.contains(WidgetState.focused) ? _anelDeFoco : null,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
          side: WidgetStateProperty.resolveWith(
            (estados) =>
                estados.contains(WidgetState.focused) ? _anelDeFoco : null,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: WidgetStateColor.resolveWith(
          (estados) => estados.contains(WidgetState.disabled) ? fundo : branco,
        ),
        constraints: const BoxConstraints(minHeight: 48),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11.5,
        ),
        border: campoBorda,
        enabledBorder: campoBorda,
        disabledBorder: campoBorda,
        focusedBorder: campoBordaDe(acaoFoco),
        errorBorder: campoBordaDe(perigo),
        focusedErrorBorder: campoBordaDe(perigo),
        hintStyle: _escala.bodyLarge!.copyWith(color: textoSecundario),
        helperStyle: _escala.labelSmall!.copyWith(color: textoSecundario),
        helperMaxLines: 2,
        errorStyle: _escala.labelSmall!.copyWith(color: perigo),
        errorMaxLines: 3,
        suffixStyle: _escala.bodyLarge!.copyWith(color: textoSecundario),
        prefixIconColor: textoSecundario,
        suffixIconColor: textoSecundario,
      ),
      cardTheme: CardThemeData(
        color: branco,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(raioCartao),
          side: const BorderSide(color: filete),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: branco,
        selectedColor: acao,
        side: const BorderSide(color: filete),
        shape: _pilula,
        showCheckmark: false,
        labelStyle: _escala.labelMedium!.copyWith(color: tinta),
        secondaryLabelStyle: _escala.labelMedium!.copyWith(color: branco),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      ),
      dividerTheme: const DividerThemeData(
        color: filete,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: branco,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(raioCartao),
        ),
        titleTextStyle: _escala.headlineSmall,
        contentTextStyle: _escala.bodySmall,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: tinta,
        elevation: 0,
        contentTextStyle: _escala.bodySmall!.copyWith(color: branco),
        actionTextColor: acaoSobreEscuro,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(raioCampo),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: branco,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        textStyle: _escala.bodyLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(raioCampo),
          side: const BorderSide(color: filete),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: fundo,
        elevation: 0,
        useIndicator: false,
        selectedIconTheme: const IconThemeData(color: acao, size: 22),
        unselectedIconTheme: const IconThemeData(
          color: textoSecundario,
          size: 22,
        ),
        selectedLabelTextStyle: _escala.labelSmall!.copyWith(
          color: acao,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: _escala.labelSmall!.copyWith(
          color: textoSecundario,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: acao,
        circularTrackColor: filete,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: tinta,
          borderRadius: BorderRadius.circular(raioCampo),
        ),
        textStyle: _escala.labelSmall!.copyWith(color: branco),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: acao,
        selectionColor: acao.withValues(alpha: 0.3),
        selectionHandleColor: acao,
      ),
    );
  }
}
