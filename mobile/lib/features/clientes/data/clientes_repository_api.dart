import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/entities/cliente.dart';
import '../domain/repositories/clientes_repository.dart';

class ClientesRepositoryApi implements ClientesRepository {
  ClientesRepositoryApi(this._api);

  static const tamanhoDaPagina = 20;

  final ApiClient _api;

  static Cliente cliente(Object? json) {
    final mapa = json as Map<String, dynamic>;
    return Cliente(
      id: mapa['id'] as String,
      nome: mapa['nome'] as String,
      documento: mapa['documento'] as String,
      telefone: mapa['telefone'] as String,
      email: mapa['email'] as String?,
      endereco: mapa['endereco'] as String?,
      ativo: mapa['ativo'] as bool,
    );
  }

  static Map<String, dynamic> _corpo(DadosDoCliente d) => {
    'nome': d.nome,
    'documento': d.documento,
    'telefone': d.telefone,
    'email': d.email,
    'endereco': d.endereco,
  };

  /// Troca o 409 de documento repetido pela exceção do domínio, com o cadastro existente.
  Future<Cliente> _gravar(Future<dynamic> Function() chamada) async {
    try {
      return cliente(await chamada());
    } on ApiException catch (erro) {
      final detalhes = erro.detalhes;
      if (erro.codigo == 'documento_duplicado' &&
          detalhes is Map &&
          detalhes['existente'] != null) {
        throw DocumentoDuplicadoException(cliente(detalhes['existente']));
      }
      rethrow;
    }
  }

  @override
  Future<PaginaDeClientes> listar(String busca, {required int pagina}) async {
    final corpo =
        await _api.chamar(
              'GET',
              '/clientes',
              query: {
                'pagina': pagina,
                'limite': tamanhoDaPagina,
                if (busca.trim().isNotEmpty) 'q': busca.trim(),
              },
            )
            as Map<String, dynamic>;
    return PaginaDeClientes(
      itens: [for (final item in corpo['itens'] as List) cliente(item)],
      total: corpo['total'] as int,
      pagina: corpo['pagina'] as int,
    );
  }

  @override
  Future<Cliente> detalhar(String id) async =>
      cliente(await _api.chamar('GET', '/clientes/$id'));

  @override
  Future<Cliente> criar(DadosDoCliente dados) =>
      _gravar(() => _api.chamar('POST', '/clientes', corpo: _corpo(dados)));

  @override
  Future<Cliente> alterar(String id, DadosDoCliente dados) => _gravar(
    () => _api.chamar('PATCH', '/clientes/$id', corpo: _corpo(dados)),
  );

  @override
  Future<Cliente> inativar(String id) async =>
      cliente(await _api.chamar('POST', '/clientes/$id/inativar'));
}
