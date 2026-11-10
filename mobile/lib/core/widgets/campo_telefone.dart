import 'package:flutter/material.dart';

import '../formatacao/telefone.dart';
import 'campo_rotulado.dart';
import 'mascara_formatter.dart';

/// Campo de telefone com DDD e máscara, com validação local.
class CampoTelefone extends StatelessWidget {
  const CampoTelefone({
    super.key,
    required this.controller,
    this.enabled = true,
  });

  final TextEditingController controller;
  final bool enabled;

  static String? validar(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Informe o telefone';
    return telefoneValido(texto)
        ? null
        : 'Telefone inválido. Use o DDD e o número.';
  }

  @override
  Widget build(BuildContext context) {
    return CampoRotulado(
      rotulo: 'Telefone',
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        inputFormatters: const [MascaraFormatter(formatarTelefone)],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: const InputDecoration(hintText: '(11) 91234-5678'),
        validator: validar,
      ),
    );
  }
}
