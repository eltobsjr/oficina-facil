import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../erro/mensagem_de_erro.dart';
import 'estados.dart';
import 'tela_com_sub_barra.dart';

/// Carrega o registro do modo editar: mostra a sub-barra com "carregando" ou com o erro e
/// "Tentar de novo", e entrega o dado pronto a [construir].
class CarregadorDeFormulario<T> extends StatelessWidget {
  const CarregadorDeFormulario({
    super.key,
    required this.dados,
    required this.titulo,
    required this.aoVoltar,
    required this.rotuloVoltar,
    required this.aoTentarDeNovo,
    required this.construir,
  });

  final AsyncValue<T> dados;
  final String titulo;
  final VoidCallback aoVoltar;
  final String rotuloVoltar;
  final VoidCallback aoTentarDeNovo;
  final Widget Function(T dado) construir;

  @override
  Widget build(BuildContext context) {
    return dados.when(
      loading: () => _tela(const Carregando()),
      error: (erro, _) => _tela(
        EstadoErro(
          mensagem: mensagemDeErro(erro),
          aoTentarDeNovo: aoTentarDeNovo,
        ),
      ),
      data: construir,
    );
  }

  Widget _tela(Widget filho) => TelaComSubBarra(
    titulo: titulo,
    aoVoltar: aoVoltar,
    rotuloVoltar: rotuloVoltar,
    filho: filho,
  );
}
