import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/entities/veiculo.dart';
import '../domain/repositories/veiculos_repository.dart';

class VeiculosRepositoryApi implements VeiculosRepository {
  VeiculosRepositoryApi(this._api);

  /// Um cliente tem poucos veículos: a lista vem numa página só, no máximo permitido pela API.
  static const limiteDaLista = 100;

  final ApiClient _api;

  static Veiculo veiculo(Object? json) {
    final mapa = json as Map<String, dynamic>;
    return Veiculo(
      id: mapa['id'] as String,
      clienteId: mapa['clienteId'] as String,
      placa: mapa['placa'] as String,
      marca: mapa['marca'] as String,
      modelo: mapa['modelo'] as String,
      ano: mapa['ano'] as int,
      cor: mapa['cor'] as String?,
      quilometragem: mapa['quilometragem'] as int,
      ativo: mapa['ativo'] as bool,
    );
  }

  static Map<String, dynamic> _corpo(DadosDoVeiculo d) => {
    'placa': d.placa,
    'marca': d.marca,
    'modelo': d.modelo,
    'ano': d.ano,
    'cor': d.cor,
    'quilometragem': d.quilometragem,
  };

  /// Troca o 409 de placa repetida pela exceção do domínio, com o veículo existente.
  Future<Veiculo> _gravar(Future<dynamic> Function() chamada) async {
    try {
      return veiculo(await chamada());
    } on ApiException catch (erro) {
      final detalhes = erro.detalhes;
      if (erro.codigo == 'placa_duplicada' &&
          detalhes is Map &&
          detalhes['existente'] != null) {
        throw PlacaDuplicadaException(veiculo(detalhes['existente']));
      }
      rethrow;
    }
  }

  @override
  Future<List<Veiculo>> doCliente(String clienteId) async {
    final corpo =
        await _api.chamar(
              'GET',
              '/clientes/$clienteId/veiculos',
              query: {'pagina': 1, 'limite': limiteDaLista},
            )
            as Map<String, dynamic>;
    return [for (final item in corpo['itens'] as List) veiculo(item)];
  }

  @override
  Future<Veiculo> detalhar(String id) async =>
      veiculo(await _api.chamar('GET', '/veiculos/$id'));

  @override
  Future<Veiculo> criar(String clienteId, DadosDoVeiculo dados) => _gravar(
    () => _api.chamar(
      'POST',
      '/clientes/$clienteId/veiculos',
      corpo: _corpo(dados),
    ),
  );

  @override
  Future<Veiculo> alterar(String id, DadosDoVeiculo dados) => _gravar(
    () => _api.chamar('PATCH', '/veiculos/$id', corpo: _corpo(dados)),
  );

  @override
  Future<Veiculo> transferir(String id, String novoClienteId) async => veiculo(
    await _api.chamar(
      'POST',
      '/veiculos/$id/transferir',
      corpo: {'clienteId': novoClienteId},
    ),
  );

  @override
  Future<Veiculo> inativar(String id) async =>
      veiculo(await _api.chamar('POST', '/veiculos/$id/inativar'));
}
