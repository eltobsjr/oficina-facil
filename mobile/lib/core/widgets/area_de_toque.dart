import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Área tocável com anel de foco de 2 px para o teclado. Base do cartão de lista e das abas.
class AreaDeToque extends StatefulWidget {
  const AreaDeToque({
    super.key,
    required this.aoTocar,
    required this.child,
    this.raio = BorderRadius.zero,
    this.cor,
    this.borda,
  });

  final VoidCallback aoTocar;
  final Widget child;
  final BorderRadius raio;

  /// Fundo da área. Sem cor, o fundo é transparente.
  final Color? cor;
  final BorderSide? borda;

  @override
  State<AreaDeToque> createState() => _AreaDeToqueState();
}

class _AreaDeToqueState extends State<AreaDeToque> {
  var _focada = false;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: widget.raio,
        border: _focada ? Border.all(color: AppTheme.acaoFoco, width: 2) : null,
      ),
      child: Material(
        color: widget.cor ?? Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: widget.raio,
          side: widget.borda ?? BorderSide.none,
        ),
        child: Semantics(
          button: true,
          child: InkWell(
            onTap: widget.aoTocar,
            onFocusChange: (focada) => setState(() => _focada = focada),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
