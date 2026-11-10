import 'package:flutter/material.dart';

import '../../../../core/formatacao/contato.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cartao_de_lista.dart';
import '../../../../core/widgets/chips.dart';
import '../../domain/entities/cliente.dart';

/// Uma linha da lista de clientes: nome, documento e telefone, e se está inativo.
class ClienteTile extends StatelessWidget {
  const ClienteTile({super.key, required this.cliente, required this.aoTocar});

  final Cliente cliente;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return CartaoDeLista(
      aoTocar: aoTocar,
      inicio: AvatarDeIniciais(cliente.nome),
      titulo: cliente.nome,
      apoio: contatoFormatado(cliente.documento, cliente.telefone),
      apagado: !cliente.ativo,
      fim: cliente.ativo
          ? const Icon(Icons.chevron_right, color: AppTheme.textoSecundario)
          : const ChipDeEstado('Inativo'),
    );
  }
}
