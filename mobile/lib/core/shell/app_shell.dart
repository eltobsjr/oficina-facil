import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/autenticacao/presentation/providers/sessao_provider.dart';
import '../widgets/perfil_rotulo.dart';
import 'menu_por_perfil.dart';

/// Moldura das telas logadas: barra de cima com o usuário e menu lateral (tela larga) ou
/// inferior (celular). O menu só aparece se o perfil tem mais de um destino.
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
      appBar: AppBar(
        title: const Text('OficinaFácil'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Conta',
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (_) => ref.read(sessaoProvider.notifier).sair(),
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Text('${usuario.nome} · ${usuario.perfil.rotulo}'),
              ),
              const PopupMenuItem<String>(value: 'sair', child: Text('Sair')),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          if (comMenu && larga)
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
          Expanded(child: filho),
        ],
      ),
      bottomNavigationBar: comMenu && !larga
          ? NavigationBar(
              selectedIndex: selecionado,
              onDestinationSelected: ir,
              destinations: [
                for (final item in itens)
                  NavigationDestination(
                    icon: Icon(item.icone),
                    label: item.rotulo,
                  ),
              ],
            )
          : null,
    );
  }
}
