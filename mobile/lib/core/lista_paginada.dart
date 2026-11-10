import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Páginas já carregadas de uma lista, com o necessário para rolar até carregar mais.
class ListaPaginada<T> {
  const ListaPaginada({
    required this.itens,
    required this.total,
    required this.pagina,
    this.carregandoMais = false,
    this.falhouAoCarregarMais = false,
  });

  final List<T> itens;
  final int total;
  final int pagina;
  final bool carregandoMais;
  final bool falhouAoCarregarMais;

  bool get temMais => itens.length < total;

  ListaPaginada<T> copiarCom({
    List<T>? itens,
    int? pagina,
    bool? carregandoMais,
    bool? falhouAoCarregarMais,
  }) {
    return ListaPaginada<T>(
      itens: itens ?? this.itens,
      total: total,
      pagina: pagina ?? this.pagina,
      carregandoMais: carregandoMais ?? this.carregandoMais,
      falhouAoCarregarMais: falhouAoCarregarMais ?? this.falhouAoCarregarMais,
    );
  }
}

/// `carregarMais` das listas paginadas. Cada notifier só diz como buscar uma página,
/// já com a busca ou o filtro vigente.
mixin CarregaMais<T> on AsyncNotifier<ListaPaginada<T>> {
  Future<ListaPaginada<T>> buscarPagina(int pagina);

  Future<void> carregarMais() async {
    final atual = state.value;
    if (atual == null || atual.carregandoMais || !atual.temMais) return;
    state = AsyncData(
      atual.copiarCom(carregandoMais: true, falhouAoCarregarMais: false),
    );
    try {
      final proxima = await buscarPagina(atual.pagina + 1);
      state = AsyncData(
        atual.copiarCom(
          itens: [...atual.itens, ...proxima.itens],
          pagina: proxima.pagina,
          carregandoMais: false,
        ),
      );
    } catch (_) {
      state = AsyncData(
        atual.copiarCom(carregandoMais: false, falhouAoCarregarMais: true),
      );
    }
  }
}
