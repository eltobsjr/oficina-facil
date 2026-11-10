import 'package:flutter/material.dart';

import 'sub_barra.dart';

/// Tela do app: sub-barra no topo e o conteúdo ocupando o resto.
class TelaComSubBarra extends StatelessWidget {
  const TelaComSubBarra({
    super.key,
    required this.titulo,
    required this.filho,
    this.aoVoltar,
    this.rotuloVoltar = 'Voltar',
    this.rotuloAcao,
    this.aoAcionar,
  });

  final String titulo;
  final Widget filho;
  final VoidCallback? aoVoltar;
  final String rotuloVoltar;
  final String? rotuloAcao;
  final VoidCallback? aoAcionar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SubBarra(
          titulo: titulo,
          aoVoltar: aoVoltar,
          rotuloVoltar: rotuloVoltar,
          rotuloAcao: rotuloAcao,
          aoAcionar: aoAcionar,
        ),
        Expanded(child: filho),
      ],
    );
  }
}
