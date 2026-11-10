import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/lista_paginada.dart';
import '../../../../core/network/api_client.dart';
import '../../data/clientes_repository_api.dart';
import '../../domain/entities/cliente.dart';
import '../../domain/repositories/clientes_repository.dart';

final clientesRepositoryProvider = Provider<ClientesRepository>(
  (ref) => ClientesRepositoryApi(ref.watch(apiClientProvider)),
);

/// Texto da busca da lista de clientes (nome ou documento).
class BuscaClientesNotifier extends Notifier<String> {
  @override
  String build() => '';

  void definir(String texto) => state = texto;
}

final buscaClientesProvider = NotifierProvider<BuscaClientesNotifier, String>(
  BuscaClientesNotifier.new,
);

class ClientesListaNotifier extends AsyncNotifier<ListaPaginada<Cliente>>
    with CarregaMais<Cliente> {
  @override
  Future<ListaPaginada<Cliente>> build() {
    ref.watch(buscaClientesProvider);
    return buscarPagina(1);
  }

  @override
  Future<ListaPaginada<Cliente>> buscarPagina(int pagina) async {
    final resultado = await ref
        .read(clientesRepositoryProvider)
        .listar(ref.read(buscaClientesProvider), pagina: pagina);
    return ListaPaginada(
      itens: resultado.itens,
      total: resultado.total,
      pagina: resultado.pagina,
    );
  }
}

final clientesListaProvider =
    AsyncNotifierProvider<ClientesListaNotifier, ListaPaginada<Cliente>>(
      ClientesListaNotifier.new,
      // Sem repetição automática: o erro aparece na tela com "Tentar de novo".
      retry: (_, _) => null,
    );

final clienteDetalheProvider = FutureProvider.autoDispose
    .family<Cliente, String>(
      (ref, id) => ref.read(clientesRepositoryProvider).detalhar(id),
      retry: (_, _) => null,
    );

/// Resultado de uma busca avulsa (primeira página), usada pelo seletor de cliente.
final clientesBuscaProvider = FutureProvider.autoDispose
    .family<PaginaDeClientes, String>(
      (ref, texto) =>
          ref.read(clientesRepositoryProvider).listar(texto, pagina: 1),
      retry: (_, _) => null,
    );
