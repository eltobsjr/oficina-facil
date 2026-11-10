import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'largura_maxima.dart';

/// Faixa escura de largura total para o dado que decide a tela. Texto branco e cinza claro;
/// links sobre ela usam [AppTheme.acaoSobreEscuro].
class TileEscuro extends StatelessWidget {
  const TileEscuro({
    super.key,
    required this.legenda,
    required this.titulo,
    this.apoio,
    this.acao,
  });

  final String legenda;
  final String titulo;
  final String? apoio;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      color: AppTheme.tileEscuro,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: LarguraMaxima(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              legenda,
              style: textos.bodySmall!.copyWith(
                color: AppTheme.textoSobreEscuroSecundario,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              titulo,
              style: textos.headlineMedium!.copyWith(color: AppTheme.branco),
            ),
            if (apoio != null)
              Text(
                apoio!,
                style: textos.titleLarge!.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textoSobreEscuroSecundario,
                ),
              ),
            if (acao != null) ...[const SizedBox(height: 8), acao!],
          ],
        ),
      ),
    );
  }
}
