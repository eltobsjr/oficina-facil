import 'package:flutter/material.dart';

import '../formatacao/placa.dart';
import 'campo_rotulado.dart';
import 'mascara_formatter.dart';

/// Campo de placa em maiúsculas, padrão antigo (ABC1234) ou Mercosul (ABC1D23).
class CampoPlaca extends StatelessWidget {
  const CampoPlaca({
    super.key,
    required this.controller,
    this.enabled = true,
    this.erro,
    this.aoMudar,
  });

  final TextEditingController controller;
  final bool enabled;

  /// Erro vindo da API (por exemplo, placa já cadastrada).
  final String? erro;
  final VoidCallback? aoMudar;

  static String? validar(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Informe a placa';
    if (!placaValida(texto)) return 'Placa inválida. Use ABC1234 ou ABC1D23.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CampoRotulado(
      rotulo: 'Placa',
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.characters,
        textInputAction: TextInputAction.next,
        inputFormatters: const [MascaraFormatter(formatarPlaca)],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: aoMudar == null ? null : (_) => aoMudar!(),
        decoration: InputDecoration(hintText: 'ABC1D23', errorText: erro),
        validator: validar,
      ),
    );
  }
}
