import 'package:flutter/material.dart';

import '../lista_paginada.dart';

/// Lista com rolagem infinita: pede mais perto do fim, mostra o rodapé de carregamento ou
/// "Tentar carregar mais" e permite puxar para atualizar.
class ListaPaginadaView<T> extends StatefulWidget {
  const ListaPaginadaView({
    super.key,
    required this.dados,
    required this.itemBuilder,
    required this.aoCarregarMais,
    required this.aoAtualizar,
  });

  final ListaPaginada<T> dados;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final VoidCallback aoCarregarMais;
  final Future<void> Function() aoAtualizar;

  @override
  State<ListaPaginadaView<T>> createState() => _ListaPaginadaViewState<T>();
}

class _ListaPaginadaViewState<T> extends State<ListaPaginadaView<T>> {
  final _rolagem = ScrollController();

  @override
  void initState() {
    super.initState();
    _rolagem.addListener(_aoRolar);
  }

  @override
  void dispose() {
    _rolagem.dispose();
    super.dispose();
  }

  void _aoRolar() {
    if (_rolagem.position.extentAfter < 300) widget.aoCarregarMais();
  }

  @override
  Widget build(BuildContext context) {
    final dados = widget.dados;
    return RefreshIndicator(
      onRefresh: widget.aoAtualizar,
      child: ListView.separated(
        controller: _rolagem,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: dados.itens.length + (dados.temMais ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, indice) {
          if (indice < dados.itens.length) {
            return widget.itemBuilder(context, dados.itens[indice]);
          }
          return dados.falhouAoCarregarMais
              ? Center(
                  child: TextButton(
                    onPressed: widget.aoCarregarMais,
                    child: const Text('Tentar carregar mais'),
                  ),
                )
              : const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  ),
                );
        },
      ),
    );
  }
}
