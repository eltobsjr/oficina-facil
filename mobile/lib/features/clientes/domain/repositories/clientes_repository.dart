import '../entities/cliente.dart';

/// Gestão de clientes (só o atendente). Erros da API sobem como `ApiException`; documento
/// repetido sobe como `DocumentoDuplicadoException`.
abstract interface class ClientesRepository {
  Future<PaginaDeClientes> listar(String busca, {required int pagina});

  Future<Cliente> detalhar(String id);

  Future<Cliente> criar(DadosDoCliente dados);

  Future<Cliente> alterar(String id, DadosDoCliente dados);

  Future<Cliente> inativar(String id);
}
