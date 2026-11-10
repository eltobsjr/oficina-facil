import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/autenticacao/presentation/providers/sessao_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/perfil_rotulo.dart';
import 'barra_de_abas.dart';
import 'barra_global.dart';
import 'menu_por_perfil.dart';

/// Moldura das telas logadas: barra global preta com a conta, e menu lateral (tela larga) ou
/// barra de abas (celular). O menu só aparece se o perfil tem mais de um destino.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.filho});

  final Widget filho;

  static const _larguraDeTelaGrande = 720.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(sessaoProvider).value;
    if (usuario == null) return filho;

    final itens = menuDoPerfil(usuario.perfil);
    final local = GoRouterState.of(context).matchedLocation;
    final selecionado = indiceSelecionado(itens, local);
    final larga = MediaQuery.sizeOf(context).width >= _larguraDeTelaGrande;
    final comMenu = itens.length > 1;

    void ir(int indice) => context.go(itens[indice].rota);

    return Scaffold(
      body: Column(
        children: [
          BarraGlobal(
            conta: _MenuDaConta(
              descricao: '${usuario.nome} · ${usuario.perfil.rotulo}',
              aoSair: () => ref.read(sessaoProvider.notifier).sair(),
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  if (comMenu && larga) ...[
                    NavigationRail(
                      selectedIndex: selecionado,
                      onDestinationSelected: ir,
                      labelType: NavigationRailLabelType.all,
                      destinations: [
                        for (final item in itens)
                          NavigationRailDestination(
                            icon: Icon(item.icone),
                            label: Text(item.rotulo),
                          ),
                      ],
                    ),
                    const VerticalDivider(),
                  ],
                  Expanded(child: filho),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: comMenu && !larga
          ? BarraDeAbas(
              itens: itens,
              selecionado: selecionado,
              aoSelecionar: ir,
            )
          : null,
    );
  }
}

/// Nome e perfil de quem está logado, com o menu que leva a "Sair".
class _MenuDaConta extends StatelessWidget {
  const _MenuDaConta({required this.descricao, required this.aoSair});

  final String descricao;
  final VoidCallback aoSair;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(
      context,
    ).textTheme.labelSmall!.copyWith(color: AppTheme.branco);
    return PopupMenuButton<String>(
      tooltip: 'Conta',
      onSelected: (_) => aoSair(),
      itemBuilder: (_) => const [
        PopupMenuItem<String>(value: 'sair', child: Text('Sair')),
      ],
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                descricao,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: estilo,
              ),
            ),
            const Icon(Icons.expand_more, size: 18, color: AppTheme.branco),
          ],
        ),
      ),
    );
  }
}
