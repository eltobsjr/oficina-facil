import 'package:flutter/material.dart';

/// Estado "carregando" de uma tela ou lista.
class Carregando extends StatelessWidget {
  const Carregando({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Estado "sem resultados" com uma mensagem e, se couber, uma ação.
class EstadoVazio extends StatelessWidget {
  const EstadoVazio({
    super.key,
    required this.mensagem,
    this.icone = Icons.inbox_outlined,
  });

  final String mensagem;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 48, color: tema.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado de erro com botão de nova tentativa.
class EstadoErro extends StatelessWidget {
  const EstadoErro({super.key, required this.mensagem, this.aoTentarDeNovo});

  final String mensagem;
  final VoidCallback? aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: tema.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyLarge,
            ),
            if (aoTentarDeNovo != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: aoTentarDeNovo,
                child: const Text('Tentar de novo'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
