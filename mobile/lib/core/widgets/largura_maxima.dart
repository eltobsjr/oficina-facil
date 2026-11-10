import 'package:flutter/material.dart';

/// Limita a largura do conteúdo em tela larga e o centraliza, sem mexer na altura.
class LarguraMaxima extends StatelessWidget {
  const LarguraMaxima({super.key, required this.child, this.largura = lista});

  /// Largura de listas e da tela inicial.
  static const lista = 720.0;

  /// Largura de formulários.
  static const formulario = 480.0;

  final Widget child;
  final double largura;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: largura),
        child: child,
      ),
    );
  }
}
