import 'package:flutter/services.dart';

/// Reformata o texto a cada edição com [formatar] e mantém o cursor no fim.
class MascaraFormatter extends TextInputFormatter {
  const MascaraFormatter(this.formatar);

  final String Function(String) formatar;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue anterior,
    TextEditingValue novo,
  ) {
    final texto = formatar(novo.text);
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
