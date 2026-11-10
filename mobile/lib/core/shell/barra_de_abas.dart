import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/area_de_toque.dart';
import '../widgets/barra_fosca.dart';
import 'menu_por_perfil.dart';

/// Barra de abas fosca na base do celular: rótulo de 12 px, aba ativa em azul de ação.
class BarraDeAbas extends StatelessWidget {
  const BarraDeAbas({
    super.key,
    required this.itens,
    required this.selecionado,
    required this.aoSelecionar,
  });

  final List<ItemMenu> itens;
  final int selecionado;
  final ValueChanged<int> aoSelecionar;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.labelSmall!;
    return BarraFosca(
      fileteEmbaixo: false,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < itens.length; i++)
              Expanded(
                child: Semantics(
                  selected: i == selecionado,
                  child: AreaDeToque(
                    aoTocar: () => aoSelecionar(i),
                    child: SizedBox(
                      height: 56,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            itens[i].icone,
                            color: i == selecionado
                                ? AppTheme.acao
                                : AppTheme.textoSecundario,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            itens[i].rotulo,
                            style: estilo.copyWith(
                              fontWeight: i == selecionado
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: i == selecionado
                                  ? AppTheme.acao
                                  : AppTheme.textoSecundario,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
