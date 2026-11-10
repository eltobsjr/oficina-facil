import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Chip de filtro: pílula com filete; selecionado vira azul de ação com texto branco.
class ChipDeFiltro extends StatelessWidget {
  const ChipDeFiltro({
    super.key,
    required this.rotulo,
    required this.selecionado,
    required this.aoSelecionar,
  });

  final String rotulo;
  final bool selecionado;
  final ValueChanged<bool> aoSelecionar;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.labelMedium!;
    return ChoiceChip(
      label: Text(rotulo),
      selected: selecionado,
      onSelected: aoSelecionar,
      labelStyle: estilo.copyWith(
        color: selecionado ? AppTheme.branco : AppTheme.tinta,
      ),
      side: BorderSide(color: selecionado ? AppTheme.acao : AppTheme.filete),
    );
  }
}

/// Chip de estado (hoje só "Inativo"): pílula apagada com o texto sempre visível.
class ChipDeEstado extends StatelessWidget {
  const ChipDeEstado(this.rotulo, {super.key});

  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const ShapeDecoration(
        color: AppTheme.fundo,
        shape: StadiumBorder(side: BorderSide(color: AppTheme.filete)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        child: Text(
          rotulo,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.tinta,
          ),
        ),
      ),
    );
  }
}
