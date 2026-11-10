import '../entities/veiculo.dart';

/// Gestão de veículos (só o atendente). Erros da API sobem como `ApiException`; placa repetida
/// sobe como `PlacaDuplicadaException`.
abstract interface class VeiculosRepository {
  Future<List<Veiculo>> doCliente(String clienteId);

  Future<Veiculo> detalhar(String id);

  Future<Veiculo> criar(String clienteId, DadosDoVeiculo dados);

  Future<Veiculo> alterar(String id, DadosDoVeiculo dados);

  Future<Veiculo> transferir(String id, String novoClienteId);

  Future<Veiculo> inativar(String id);
}
