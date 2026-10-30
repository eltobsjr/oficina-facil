import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/perfil_rotulo.dart';
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

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, ${usuario.nome}',
                style: tema.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Chip(label: Text(usuario.perfil.rotulo)),
              const SizedBox(height: 24),
              if (atalhos.isEmpty)
                Text(
                  'As funções do seu perfil chegam nas próximas semanas.',
                  style: tema.textTheme.bodyLarge,
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final atalho in atalhos)
                      ActionChip(
                        avatar: Icon(atalho.icone),
                        label: Text(atalho.rotulo),
                        onPressed: () => context.go(atalho.rota),
                      ),
                  ],
                ),
              const SizedBox(height: 48),
              const ApiStatus(),
            ],
          ),
        ),
      ),
    );
  }
}
