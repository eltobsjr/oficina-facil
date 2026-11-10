import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/lista_paginada.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/perfil.dart';
import '../../data/usuarios_repository_api.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuarios_repository.dart';

final usuariosRepositoryProvider = Provider<UsuariosRepository>(
  (ref) => UsuariosRepositoryApi(ref.watch(apiClientProvider)),
);

/// Busca e filtros da lista de usuários.
class FiltroUsuariosNotifier extends Notifier<FiltroUsuarios> {
  @override
  FiltroUsuarios build() => const FiltroUsuarios();

  void definirTexto(String texto) => state = state.copiarCom(texto: texto);

  void definirPerfil(Perfil? perfil) => state = state.copiarCom(perfil: perfil);

  void definirAtivo(bool? ativo) => state = state.copiarCom(ativo: ativo);
}

final filtroUsuariosProvider =
    NotifierProvider<FiltroUsuariosNotifier, FiltroUsuarios>(
      FiltroUsuariosNotifier.new,
    );

class UsuariosListaNotifier extends AsyncNotifier<ListaPaginada<Usuario>>
    with CarregaMais<Usuario> {
  @override
  Future<ListaPaginada<Usuario>> build() {
    ref.watch(filtroUsuariosProvider);
    return buscarPagina(1);
  }

  @override
  Future<ListaPaginada<Usuario>> buscarPagina(int pagina) async {
    final resultado = await ref
        .read(usuariosRepositoryProvider)
        .listar(ref.read(filtroUsuariosProvider), pagina: pagina);
    return ListaPaginada(
      itens: resultado.itens,
      total: resultado.total,
      pagina: resultado.pagina,
    );
  }
}

final usuariosListaProvider =
    AsyncNotifierProvider<UsuariosListaNotifier, ListaPaginada<Usuario>>(
      UsuariosListaNotifier.new,
      // Sem repetição automática: o erro aparece na tela com "Tentar de novo".
      retry: (_, _) => null,
    );

final usuarioDetalheProvider = FutureProvider.autoDispose
    .family<Usuario, String>(
      (ref, id) => ref.read(usuariosRepositoryProvider).detalhar(id),
      retry: (_, _) => null,
    );
