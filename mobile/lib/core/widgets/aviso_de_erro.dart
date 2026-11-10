import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Aviso de erro geral do formulário ou da tela: perigo sobre fundo de perigo, lido pelo leitor de tela.
class AvisoDeErro extends StatelessWidget {
  const AvisoDeErro(this.mensagem, {super.key});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.perigoSuperficie,
          borderRadius: BorderRadius.circular(AppTheme.raioCartao),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            mensagem,
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: AppTheme.perigo),
          ),
        ),
      ),
    );
  }
}
