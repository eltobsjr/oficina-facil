import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Barra global preta de 44 px: nome do app à esquerda e, se houver, a conta à direita.
/// O preto avança sob a barra de status do aparelho.
class BarraGlobal extends StatelessWidget {
  const BarraGlobal({super.key, this.conta});

  final Widget? conta;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(
      context,
    ).textTheme.labelSmall!.copyWith(color: AppTheme.branco);
    return ColoredBox(
      color: AppTheme.preto,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.viewPaddingOf(context).top),
        child: SizedBox(
          height: 44,
          child: Row(
            children: [
              const SizedBox(width: 20),
              Text(
                'OficinaFácil',
                style: estilo.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (conta != null) Flexible(child: conta!),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
