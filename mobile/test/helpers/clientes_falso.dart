import 'package:oficina_facil/core/network/api_exception.dart';
import 'package:oficina_facil/features/clientes/domain/entities/cliente.dart';
import 'package:oficina_facil/features/clientes/domain/repositories/clientes_repository.dart';

/// Todos os dados são fictícios (R28). Os documentos abaixo passam no dígito verificador.
const cpfAna = '52998224725';
const cpfBruno = '11144477735';

Cliente cliente(
  String id, {
  String? nome,
  String documento = cpfAna,
  String telefone = '11912345678',
  String? email,
  String? endereco,
  bool ativo = true,
}) => Cliente(
  id: id,
  nome: nome ?? 'Cliente $id',
  documento: documento,
  telefone: telefone,
  email: email,
  endereco: endereco,
  ativo: ativo,
);

/// Repositório de clientes em memória, com registro das chamadas e falhas injetáveis.
class ClientesFalso implements ClientesRepository {
  ClientesFalso(List<Cliente> iniciais, {this.tamanhoDaPagina = 20})
    : clientes = [...iniciais];

  final List<Cliente> clientes;
  final int tamanhoDaPagina;

  /// Falha lançada pela próxima operação (e só por ela).
  Object? falharNaProxima;

  /// Enquanto `true`, toda listagem da segunda página em diante falha (a primeira funciona).
  var falharPaginasSeguintes = false;

  final listagens = <(String, int)>[];
  final criacoes = <DadosDoCliente>[];
  final alteracoes = <(String, DadosDoCliente)>[];
  final inativados = <String>[];

  void _falhaSeHouver() {
    final falha = falharNaProxima;
    if (falha != null) {
      falharNaProxima = null;
      throw falha;
    }
  }

  Cliente _achar(String id) => clientes.firstWhere(
    (c) => c.id == id,
    orElse: () => throw const ApiException(
      status: 404,
      codigo: 'nao_encontrado',
      mensagem: 'Cliente não encontrado',
    ),
  );

  Cliente? _comDocumento(String documento) {
    for (final c in clientes) {
      if (c.documento == documento) return c;
    }
    return null;
  }

  @override
  Future<PaginaDeClientes> listar(String busca, {required int pagina}) async {
    listagens.add((busca, pagina));
    _falhaSeHouver();
    if (falharPaginasSeguintes && pagina > 1) throw const SemConexaoException();
    final texto = busca.trim().toLowerCase();
    final digitos = texto.replaceAll(RegExp(r'\D'), '');
    final filtrados = clientes
        .where(
          (c) =>
              texto.isEmpty ||
              c.nome.toLowerCase().contains(texto) ||
              (digitos.isNotEmpty && c.documento.contains(digitos)),
        )
        .toList();
    final inicio = (pagina - 1) * tamanhoDaPagina;
    return PaginaDeClientes(
      itens: filtrados.skip(inicio).take(tamanhoDaPagina).toList(),
      total: filtrados.length,
      pagina: pagina,
    );
  }

  @override
  Future<Cliente> detalhar(String id) async {
    _falhaSeHouver();
    return _achar(id);
  }

  @override
  Future<Cliente> criar(DadosDoCliente dados) async {
    _falhaSeHouver();
    criacoes.add(dados);
    final existente = _comDocumento(dados.documento);
    if (existente != null) throw DocumentoDuplicadoException(existente);
    final novo = Cliente(
      id: 'novo-${clientes.length}',
      nome: dados.nome,
      documento: dados.documento,
      telefone: dados.telefone,
      email: dados.email,
      endereco: dados.endereco,
      ativo: true,
    );
    clientes.add(novo);
    return novo;
  }

  @override
  Future<Cliente> alterar(String id, DadosDoCliente dados) async {
    _falhaSeHouver();
    alteracoes.add((id, dados));
    final atual = _achar(id);
    final novo = Cliente(
      id: atual.id,
      nome: dados.nome,
      documento: dados.documento,
      telefone: dados.telefone,
      email: dados.email,
      endereco: dados.endereco,
      ativo: atual.ativo,
    );
    clientes[clientes.indexWhere((c) => c.id == id)] = novo;
    return novo;
  }

  @override
  Future<Cliente> inativar(String id) async {
    _falhaSeHouver();
    inativados.add(id);
    final atual = _achar(id);
    final novo = Cliente(
      id: atual.id,
      nome: atual.nome,
      documento: atual.documento,
      telefone: atual.telefone,
      email: atual.email,
      endereco: atual.endereco,
      ativo: false,
    );
    clientes[clientes.indexWhere((c) => c.id == id)] = novo;
    return novo;
  }
}
