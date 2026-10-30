import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/estados.dart';
import '../providers/sessao_provider.dart';

/// Espera enquanto o app confirma a sessão guardada com o servidor.
class CarregandoSessaoPage extends StatelessWidget {
  const CarregandoSessaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Carregando());
  }
}

/// A sessão não pôde ser confirmada porque o servidor não respondeu.
class SemConexaoPage extends ConsumerWidget {
  const SemConexaoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: EstadoErro(
        mensagem:
            'Sem conexão com o servidor. Verifique a internet e tente de novo.',
        aoTentarDeNovo: () => ref.invalidate(sessaoProvider),
      ),
    );
  }
}
