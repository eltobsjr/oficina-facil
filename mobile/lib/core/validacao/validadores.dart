import 'package:flutter/widgets.dart';

/// Validadores de campo de texto: cada um devolve a mensagem de erro ou `null` se o valor serve.
abstract final class Validadores {
  static final _formatoDeEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Campo que não pode ficar vazio. [aparar] ignora espaços nas pontas (use `false` em senha).
  static FormFieldValidator<String> obrigatorio(
    String mensagem, {
    bool aparar = true,
  }) {
    return (valor) {
      final texto = aparar ? valor?.trim() : valor;
      return (texto == null || texto.isEmpty) ? mensagem : null;
    };
  }

  /// Texto com pelo menos [tamanho] caracteres, sem contar os espaços das pontas.
  static FormFieldValidator<String> textoMinimo(int tamanho, String mensagem) {
    return (valor) =>
        (valor == null || valor.trim().length < tamanho) ? mensagem : null;
  }

  /// E-mail obrigatório, com um `@` no meio.
  static String? emailObrigatorio(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Informe o e-mail';
    if (!texto.contains('@')) return 'E-mail inválido';
    return null;
  }

  /// E-mail que pode ficar vazio; se preenchido, precisa ter o formato `nome@dominio.ext`.
  static String? emailOpcional(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return null;
    return _formatoDeEmail.hasMatch(texto) ? null : 'E-mail inválido';
  }

  /// Senha com no mínimo 8 caracteres (espaços contam).
  static String? senhaMinima(String? valor) {
    return (valor == null || valor.length < 8)
        ? 'A senha precisa ter pelo menos 8 caracteres'
        : null;
  }

  /// Número inteiro obrigatório. [vazio] vale para campo em branco; [invalido] para texto que não
  /// é número ou que fica fora de [minimo] e [maximo].
  static FormFieldValidator<String> inteiroEntre({
    required String vazio,
    required String invalido,
    int? minimo,
    int? maximo,
  }) {
    return (valor) {
      final texto = valor?.trim() ?? '';
      if (texto.isEmpty) return vazio;
      final numero = int.tryParse(texto);
      if (numero == null) return invalido;
      if (minimo != null && numero < minimo) return invalido;
      if (maximo != null && numero > maximo) return invalido;
      return null;
    };
  }
}
