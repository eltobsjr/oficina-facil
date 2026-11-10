import 'package:flutter/material.dart';

/// Campo de formulário com o rótulo sempre visível acima, nunca só como dica.
/// O campo ([child]) não leva `labelText`: o rótulo e o texto de apoio ficam por conta daqui.
class CampoRotulado extends StatelessWidget {
  const CampoRotulado({super.key, required this.rotulo, required this.child});

  final String rotulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(child: Text(rotulo, style: tema.textTheme.bodySmall)),
        const SizedBox(height: 4),
        MergeSemantics(
          child: Semantics(label: rotulo, child: child),
        ),
      ],
    );
  }
}
