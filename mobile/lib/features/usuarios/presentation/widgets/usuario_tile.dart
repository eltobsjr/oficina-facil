import 'package:flutter/material.dart';

import '../../../../core/widgets/perfil_rotulo.dart';
import '../../domain/entities/usuario.dart';

/// Uma linha da lista de usuários: nome, e-mail, perfil e se está inativo.
class UsuarioTile extends StatelessWidget {
  const UsuarioTile({super.key, required this.usuario, required this.aoTocar});

  final Usuario usuario;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ListTile(
      onTap: aoTocar,
      leading: CircleAvatar(
        backgroundColor: usuario.ativo
            ? tema.colorScheme.primaryContainer
            : tema.colorScheme.surfaceContainerHighest,
        child: Text(usuario.nome.isEmpty ? '?' : usuario.nome[0].toUpperCase()),
      ),
      title: Text(usuario.nome),
      subtitle: Text('${usuario.email} · ${usuario.perfil.rotulo}'),
      trailing: usuario.ativo ? null : const Chip(label: Text('Inativo')),
    );
  }
}
