import 'package:flutter/material.dart';

import '../../../core/perfil.dart';
import '../../../core/router/redirecionamento.dart';

class Atalho {
  const Atalho({required this.rotulo, required this.rota, required this.icone});

  final String rotulo;
  final String rota;
  final IconData icone;
}

/// Atalhos da tela inicial de cada perfil. Só telas que já existem; cresce a cada fase.
List<Atalho> atalhosDoPerfil(Perfil perfil) {
  return [
    if (perfil == Perfil.gerente)
      const Atalho(
        rotulo: 'Usuários',
        rota: AppRoutes.usuarios,
        icone: Icons.group_outlined,
      ),
  ];
}
