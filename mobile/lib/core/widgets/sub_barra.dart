import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'barra_fosca.dart';

/// Sub-barra fosca: título da tela e, à direita, a ação principal em pílula.
/// Com [aoVoltar] mostra a seta de voltar no lugar do recuo inicial.
class SubBarra extends StatelessWidget {
  const SubBarra({
    super.key,
    required this.titulo,
    this.aoVoltar,
    this.rotuloVoltar = 'Voltar',
    this.rotuloAcao,
    this.aoAcionar,
  });

  final String titulo;
  final VoidCallback? aoVoltar;
  final String rotuloVoltar;
  final String? rotuloAcao;
  final VoidCallback? aoAcionar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return BarraFosca(
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            if (aoVoltar != null)
              IconButton(
                tooltip: rotuloVoltar,
                color: AppTheme.acao,
                onPressed: aoVoltar,
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              )
            else
              const SizedBox(width: 20),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tema.textTheme.headlineSmall,
                ),
              ),
            ),
            if (rotuloAcao != null) ...[
              const SizedBox(width: 8),
              FilledButton(
                style: AppTheme.estiloAcaoDaSubBarra,
                onPressed: aoAcionar,
                child: Text(rotuloAcao!),
              ),
            ],
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
