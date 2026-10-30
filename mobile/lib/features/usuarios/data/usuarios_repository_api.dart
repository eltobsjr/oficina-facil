import '../../../core/network/api_client.dart';
import '../../../core/perfil.dart';
import '../domain/entities/usuario.dart';
import '../domain/repositories/usuarios_repository.dart';

class UsuariosRepositoryApi implements UsuariosRepository {
  UsuariosRepositoryApi(this._api);

  static const tamanhoDaPagina = 20;

  final ApiClient _api;

  static Usuario _usuario(Object? json) {
    final mapa = json as Map<String, dynamic>;
    return Usuario(
      id: mapa['id'] as String,
      nome: mapa['nome'] as String,
      email: mapa['email'] as String,
      perfil: Perfil.fromApi(mapa['perfil'] as String),
      ativo: mapa['ativo'] as bool,
      criadoEm: DateTime.parse(mapa['criadoEm'] as String),
    );
  }

  @override
  Future<PaginaDeUsuarios> listar(
    FiltroUsuarios filtro, {
    required int pagina,
  }) async {
    final corpo =
        await _api.chamar(
              'GET',
              '/usuarios',
              query: {
                'pagina': pagina,
                'limite': tamanhoDaPagina,
                if (filtro.texto.trim().isNotEmpty) 'q': filtro.texto.trim(),
                if (filtro.perfil != null) 'perfil': filtro.perfil!.toApi(),
                if (filtro.ativo != null) 'ativo': filtro.ativo.toString(),
              },
            )
            as Map<String, dynamic>;
    return PaginaDeUsuarios(
      itens: [for (final item in corpo['itens'] as List) _usuario(item)],
      total: corpo['total'] as int,
      pagina: corpo['pagina'] as int,
    );
  }

  @override
  Future<Usuario> detalhar(String id) async =>
      _usuario(await _api.chamar('GET', '/usuarios/$id'));

  @override
  Future<Usuario> criar({
    required String nome,
    required String email,
    required Perfil perfil,
    required String senha,
  }) async => _usuario(
    await _api.chamar(
      'POST',
      '/usuarios',
      corpo: {
        'nome': nome,
        'email': email,
        'perfil': perfil.toApi(),
        'senha': senha,
      },
    ),
  );

  @override
  Future<Usuario> alterar(String id, {String? nome, Perfil? perfil}) async =>
      _usuario(
        await _api.chamar(
          'PATCH',
          '/usuarios/$id',
          corpo: {'nome': ?nome, 'perfil': ?perfil?.toApi()},
        ),
      );

  @override
  Future<void> redefinirSenha(String id, String senha) async {
    await _api.chamar(
      'POST',
      '/usuarios/$id/redefinir-senha',
      corpo: {'senha': senha},
    );
  }

  @override
  Future<Usuario> inativar(String id) async =>
      _usuario(await _api.chamar('POST', '/usuarios/$id/inativar'));

  @override
  Future<Usuario> ativar(String id) async =>
      _usuario(await _api.chamar('POST', '/usuarios/$id/ativar'));
}
