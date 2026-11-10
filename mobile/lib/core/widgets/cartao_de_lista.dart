import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'area_de_toque.dart';

/// Item de lista no cartão do design system: branco, filete de 1 px, raio 18, sem sombra.
/// Nome em destaque, apoio em letra menor e um elemento opcional em cada ponta.
class CartaoDeLista extends StatelessWidget {
  const CartaoDeLista({
    super.key,
    required this.aoTocar,
    required this.titulo,
    this.apoio,
    this.inicio,
    this.fim,
    this.estiloDoTitulo,
    this.apagado = false,
  });

  final VoidCallback aoTocar;
  final String titulo;
  final String? apoio;
  final Widget? inicio;
  final Widget? fim;
  final TextStyle? estiloDoTitulo;

  /// Item inativo: o nome perde destaque (o estado vem num [ChipDeEstado], nunca por opacidade).
  final bool apagado;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final estiloBase = textos.titleMedium!.copyWith(
      color: apagado ? AppTheme.textoSecundario : AppTheme.tinta,
    );
    return AreaDeToque(
      aoTocar: aoTocar,
      raio: BorderRadius.circular(AppTheme.raioCartao),
      cor: AppTheme.branco,
      borda: const BorderSide(color: AppTheme.filete),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 72),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (inicio != null) ...[inicio!, const SizedBox(width: 12)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titulo,
                      style: estiloDoTitulo == null
                          ? estiloBase
                          : estiloBase.merge(estiloDoTitulo),
                    ),
                    if (apoio != null) Text(apoio!, style: textos.bodySmall),
                  ],
                ),
              ),
              if (fim != null) ...[const SizedBox(width: 12), fim!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Círculo de 40 px com as iniciais do nome (primeira e última palavra).
class AvatarDeIniciais extends StatelessWidget {
  const AvatarDeIniciais(this.nome, {super.key});

  final String nome;

  String get _iniciais {
    final palavras = nome
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty);
    if (palavras.isEmpty) return '?';
    final primeira = palavras.first[0];
    final ultima = palavras.length > 1 ? palavras.last[0] : '';
    return (primeira + ultima).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: const ShapeDecoration(
          color: AppTheme.fundo,
          shape: CircleBorder(side: BorderSide(color: AppTheme.filete)),
        ),
        child: Text(_iniciais, style: Theme.of(context).textTheme.titleSmall),
      ),
    );
  }
}
