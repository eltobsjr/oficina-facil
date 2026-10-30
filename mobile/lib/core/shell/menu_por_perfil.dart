import 'package:flutter/material.dart';

import '../perfil.dart';
import '../router/redirecionamento.dart';

class ItemMenu {
  const ItemMenu({
    required this.rotulo,
    required this.rota,
    required this.icone,
  });

  final String rotulo;
  final String rota;
  final IconData icone;
}

/// Itens do menu de cada perfil. Só entram telas que já existem; cresce a cada fase.
List<ItemMenu> menuDoPerfil(Perfil perfil) {
  return [
    const ItemMenu(
      rotulo: 'Início',
      rota: AppRoutes.inicio,
      icone: Icons.home_outlined,
    ),
    if (perfil == Perfil.gerente)
      const ItemMenu(
        rotulo: 'Usuários',
        rota: AppRoutes.usuarios,
        icone: Icons.group_outlined,
      ),
  ];
}

/// Índice do item que corresponde à rota atual (Início só casa com `/`).
int indiceSelecionado(List<ItemMenu> itens, String rota) {
  for (var i = itens.length - 1; i >= 0; i--) {
    final item = itens[i];
    if (item.rota == AppRoutes.inicio) {
      if (rota == AppRoutes.inicio) return i;
    } else if (rota == item.rota || rota.startsWith('${item.rota}/')) {
      return i;
    }
  }
  return 0;
}
