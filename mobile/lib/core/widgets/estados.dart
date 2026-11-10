import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Estado "carregando" de uma tela ou lista.
class Carregando extends StatelessWidget {
  const Carregando({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(semanticsLabel: 'Carregando'),
    );
  }
}

/// Estado "sem resultados" com uma mensagem.
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 48, color: AppTheme.textoSecundario),
            const SizedBox(height: 12),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado de erro com botão de nova tentativa. Com [titulo], mostra um título acima da mensagem.
class EstadoErro extends StatelessWidget {
  const EstadoErro({
    super.key,
    required this.mensagem,
    this.aoTentarDeNovo,
    this.titulo,
    this.icone = Icons.error_outline,
  });

  final String mensagem;
  final VoidCallback? aoTentarDeNovo;
  final String? titulo;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icone,
              size: 48,
              color: titulo == null
                  ? AppTheme.perigo
                  : AppTheme.textoSecundario,
            ),
            const SizedBox(height: 12),
            if (titulo != null) ...[
              Semantics(
                header: true,
                child: Text(
                  titulo!,
                  textAlign: TextAlign.center,
                  style: textos.headlineLarge,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: titulo == null ? textos.bodyLarge : textos.bodySmall,
            ),
            if (aoTentarDeNovo != null) ...[
              const SizedBox(height: 24),
              FilledButton(
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
