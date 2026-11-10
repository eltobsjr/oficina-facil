import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shell/moldura_de_entrada.dart';
import '../../../../core/widgets/estados.dart';
import '../providers/sessao_provider.dart';

/// Espera enquanto o app confirma a sessão guardada com o servidor.
class CarregandoSessaoPage extends StatelessWidget {
  const CarregandoSessaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MolduraDeEntrada(
      filho: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                'assets/images/logo.png',
                width: 96,
                height: 96,
                semanticLabel: 'Logo do OficinaFácil',
              ),
            ),
            const SizedBox(height: 24),
            const Carregando(),
            const SizedBox(height: 24),
            Text(
              'Abrindo sua sessão…',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// A sessão não pôde ser confirmada porque o servidor não respondeu.
class SemConexaoPage extends ConsumerWidget {
  const SemConexaoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MolduraDeEntrada(
      filho: EstadoErro(
        titulo: 'Sem conexão',
        icone: Icons.wifi_off,
        mensagem:
            'Sem conexão com o servidor. Verifique a internet e tente de novo.',
        aoTentarDeNovo: () => ref.invalidate(sessaoProvider),
      ),
    );
  }
}
