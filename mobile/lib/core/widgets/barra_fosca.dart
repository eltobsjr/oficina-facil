import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Barra fosca do design system: parchment a 80% com desfoque e um filete na borda de dentro.
class BarraFosca extends StatelessWidget {
  const BarraFosca({super.key, required this.child, this.fileteEmbaixo = true});

  final Widget child;

  /// `true` para a sub-barra (filete embaixo); `false` para a barra de abas (filete em cima).
  final bool fileteEmbaixo;

  @override
  Widget build(BuildContext context) {
    const filete = BorderSide(color: AppTheme.filete);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.fundoFosco,
            border: fileteEmbaixo
                ? const Border(bottom: filete)
                : const Border(top: filete),
          ),
          child: child,
        ),
      ),
    );
  }
}
