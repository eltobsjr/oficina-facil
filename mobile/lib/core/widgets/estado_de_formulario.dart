import 'package:flutter/material.dart';

import '../erro/mensagem_de_erro.dart';

/// Estado comum das telas de formulário: se está [salvando], o [erroGeral] e o aviso na parte
/// de baixo da tela. O formulário que tem erro próprio de campo (documento duplicado, e-mail em
/// conflito) sobrescreve [limparErros] e [tratarErro].
mixin EstadoDeFormulario<T extends StatefulWidget> on State<T> {
  var salvando = false;
  String? erroGeral;

  /// Roda no início de cada ação, dentro do `setState`, para apagar erros de campo antigos.
  void limparErros() {}

  /// Recebe o erro da ação, dentro do `setState`. Devolve `true` se o formulário o mostrou num
  /// campo; `false` deixa o erro virar o [erroGeral].
  bool tratarErro(Object erro) => false;

  void mostrar(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  /// Faz a ação, mostra o erro em português se falhar e devolve se deu certo.
  Future<bool> executar(Future<void> Function() acao) async {
    setState(() {
      salvando = true;
      erroGeral = null;
      limparErros();
    });
    try {
      await acao();
      return true;
    } catch (erro) {
      if (!mounted) return false;
      setState(() {
        if (!tratarErro(erro)) erroGeral = mensagemDeErro(erro);
      });
      return false;
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }
}
