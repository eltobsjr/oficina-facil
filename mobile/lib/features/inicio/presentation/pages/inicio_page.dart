import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/cartao_de_lista.dart';
import '../../../../core/widgets/largura_maxima.dart';
import '../../../../core/widgets/perfil_rotulo.dart';
import '../../../../core/widgets/tela_com_sub_barra.dart';
import '../../../../core/widgets/tile_escuro.dart';
import '../../../autenticacao/presentation/providers/sessao_provider.dart';
import '../atalhos_do_perfil.dart';
import '../widgets/api_status.dart';

/// T02: início de cada perfil, com saudação e atalhos para o que ele pode fazer.
class InicioPage extends ConsumerWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(sessaoProvider).value;
    if (usuario == null) return const SizedBox.shrink();
    final tema = Theme.of(context);
    final atalhos = atalhosDoPerfil(usuario.perfil);

    return TelaComSubBarra(
      titulo: 'Início',
      filho: SingleChildScrollView(
        child: Column(
          children: [
            TileEscuro(
              legenda: usuario.perfil.rotulo,
              titulo: 'Olá, ${usuario.nome}',
            ),
            LarguraMaxima(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (atalhos.isEmpty)
                      Text(
                        'As funções do seu perfil chegam nas próximas semanas.',
                        style: tema.textTheme.bodyLarge,
                      )
                    else ...[
                      Text('Atalhos', style: tema.textTheme.titleSmall),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, restricoes) {
                          final largura = (restricoes.maxWidth - 12) / 2;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (final atalho in atalhos)
                                SizedBox(
                                  width: largura,
                                  child: CartaoDeLista(
                                    aoTocar: () => context.go(atalho.rota),
                                    titulo: atalho.rotulo,
                                    inicio: Icon(atalho.icone),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 32),
                    const ApiStatus(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
