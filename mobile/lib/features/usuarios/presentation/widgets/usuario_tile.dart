import 'package:flutter/material.dart';

import '../../../../core/widgets/cartao_de_lista.dart';
import '../../../../core/widgets/chips.dart';
import '../../../../core/widgets/perfil_rotulo.dart';
import '../../domain/entities/usuario.dart';

/// Uma linha da lista de usuários: nome, e-mail e perfil, ou o chip de inativo.
class UsuarioTile extends StatelessWidget {
  const UsuarioTile({super.key, required this.usuario, required this.aoTocar});

  final Usuario usuario;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return CartaoDeLista(
      aoTocar: aoTocar,
      inicio: AvatarDeIniciais(usuario.nome),
      titulo: usuario.nome,
      apoio: usuario.email,
      apagado: !usuario.ativo,
      fim: usuario.ativo
          ? Text(
              usuario.perfil.rotulo,
              style: Theme.of(context).textTheme.labelSmall,
            )
          : const ChipDeEstado('Inativo'),
    );
  }
}
