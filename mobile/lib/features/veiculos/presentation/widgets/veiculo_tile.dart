import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cartao_de_lista.dart';
import '../../../../core/widgets/chips.dart';
import '../../domain/entities/veiculo.dart';

/// Uma linha da lista de veículos: placa, marca, modelo, ano e se está inativo.
class VeiculoTile extends StatelessWidget {
  const VeiculoTile({super.key, required this.veiculo, required this.aoTocar});

  final Veiculo veiculo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return CartaoDeLista(
      aoTocar: aoTocar,
      inicio: const Icon(Icons.directions_car_outlined),
      titulo: veiculo.placa,
      estiloDoTitulo: const TextStyle(letterSpacing: 0.68),
      apoio: '${veiculo.marca} ${veiculo.modelo} · ${veiculo.ano}',
      apagado: !veiculo.ativo,
      fim: veiculo.ativo
          ? const Icon(Icons.chevron_right, color: AppTheme.textoSecundario)
          : const ChipDeEstado('Inativo'),
    );
  }
}
