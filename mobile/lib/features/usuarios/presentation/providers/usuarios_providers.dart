import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Páginas já carregadas da lista, com o necessário para rolar até carregar mais.
class ListaDeUsuarios {
  const ListaDeUsuarios({
    required this.itens,
    required this.total,
    required this.pagina,
    this.carregandoMais = false,
    this.falhouAoCarregarMais = false,
  });

  final List<Usuario> itens;
  final int total;
  final int pagina;
  final bool carregandoMais;
  final bool falhouAoCarregarMais;

  bool get temMais => itens.length < total;

  ListaDeUsuarios copiarCom({
    List<Usuario>? itens,
    int? pagina,
    bool? carregandoMais,
    bool? falhouAoCarregarMais,
  }) {
    return ListaDeUsuarios(
      itens: itens ?? this.itens,
      total: total,
      pagina: pagina ?? this.pagina,
      carregandoMais: carregandoMais ?? this.carregandoMais,
      falhouAoCarregarMais: falhouAoCarregarMais ?? this.falhouAoCarregarMais,
    );
  }
}

class UsuariosListaNotifier extends AsyncNotifier<ListaDeUsuarios> {
  @override
  Future<ListaDeUsuarios> build() async {
    final filtro = ref.watch(filtroUsuariosProvider);
    final primeira = await ref
        .read(usuariosRepositoryProvider)
        .listar(filtro, pagina: 1);
    return ListaDeUsuarios(
      itens: primeira.itens,
      total: primeira.total,
      pagina: 1,
    );
  }

  Future<void> carregarMais() async {
    final atual = state.value;
    if (atual == null || atual.carregandoMais || !atual.temMais) return;
    state = AsyncData(
      atual.copiarCom(carregandoMais: true, falhouAoCarregarMais: false),
    );
    try {
      final proxima = await ref
          .read(usuariosRepositoryProvider)
          .listar(ref.read(filtroUsuariosProvider), pagina: atual.pagina + 1);
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

final usuariosListaProvider =
    AsyncNotifierProvider<UsuariosListaNotifier, ListaDeUsuarios>(
      UsuariosListaNotifier.new,
      // Sem repetição automática: o erro aparece na tela com "Tentar de novo".
      retry: (_, _) => null,
    );

final usuarioDetalheProvider = FutureProvider.autoDispose
    .family<Usuario, String>(
      (ref, id) => ref.read(usuariosRepositoryProvider).detalhar(id),
      retry: (_, _) => null,
    );
