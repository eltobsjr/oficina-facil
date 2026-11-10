import 'package:flutter/material.dart';

import '../formatacao/documento.dart';
import 'campo_rotulado.dart';
import 'mascara_formatter.dart';

/// Campo de CPF ou CNPJ com máscara e validação local dos dígitos verificadores.
/// A API valida de novo (R14): aqui só se ajuda o usuário.
class CampoDocumento extends StatelessWidget {
  const CampoDocumento({
    super.key,
    required this.controller,
    this.enabled = true,
    this.erro,
    this.aoMudar,
  });

  final TextEditingController controller;
  final bool enabled;

  /// Erro vindo da API (por exemplo, documento já cadastrado).
  final String? erro;
  final VoidCallback? aoMudar;

  static String? validar(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Informe o CPF ou CNPJ';
    if (!documentoValido(texto)) return 'CPF ou CNPJ inválido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CampoRotulado(
      rotulo: 'CPF ou CNPJ',
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        inputFormatters: const [MascaraFormatter(formatarDocumento)],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: aoMudar == null ? null : (_) => aoMudar!(),
        decoration: InputDecoration(errorText: erro),
        validator: validar,
      ),
    );
  }
}
