import 'package:oficina_facil/core/network/api_exception.dart';
import 'package:oficina_facil/features/veiculos/domain/entities/veiculo.dart';
import 'package:oficina_facil/features/veiculos/domain/repositories/veiculos_repository.dart';

Veiculo veiculo(
  String id, {
  String clienteId = 'c1',
  String placa = 'ABC1234',
  String marca = 'Fiat',
  String modelo = 'Uno',
  int ano = 2015,
  String? cor,
  int quilometragem = 80000,
  bool ativo = true,
}) => Veiculo(
  id: id,
  clienteId: clienteId,
  placa: placa,
  marca: marca,
  modelo: modelo,
  ano: ano,
  cor: cor,
  quilometragem: quilometragem,
  ativo: ativo,
);

/// Repositório de veículos em memória, com registro das chamadas e falhas injetáveis.
class VeiculosFalso implements VeiculosRepository {
  VeiculosFalso(List<Veiculo> iniciais) : veiculos = [...iniciais];

  final List<Veiculo> veiculos;

  /// Falha lançada pela próxima operação (e só por ela).
  Object? falharNaProxima;

  final criacoes = <(String, DadosDoVeiculo)>[];
  final alteracoes = <(String, DadosDoVeiculo)>[];
  final transferencias = <(String, String)>[];
  final inativados = <String>[];

  void _falhaSeHouver() {
    final falha = falharNaProxima;
    if (falha != null) {
      falharNaProxima = null;
      throw falha;
    }
  }

  Veiculo _achar(String id) => veiculos.firstWhere(
    (v) => v.id == id,
    orElse: () => throw const ApiException(
      status: 404,
      codigo: 'nao_encontrado',
      mensagem: 'Veículo não encontrado',
    ),
  );

  void _substituir(Veiculo novo) {
    veiculos[veiculos.indexWhere((v) => v.id == novo.id)] = novo;
  }

  Veiculo _copiar(
    Veiculo v, {
    String? clienteId,
    bool? ativo,
    DadosDoVeiculo? dados,
  }) => Veiculo(
    id: v.id,
    clienteId: clienteId ?? v.clienteId,
    placa: dados?.placa ?? v.placa,
    marca: dados?.marca ?? v.marca,
    modelo: dados?.modelo ?? v.modelo,
    ano: dados?.ano ?? v.ano,
    cor: dados == null ? v.cor : dados.cor,
    quilometragem: dados?.quilometragem ?? v.quilometragem,
    ativo: ativo ?? v.ativo,
  );

  @override
  Future<List<Veiculo>> doCliente(String clienteId) async {
    _falhaSeHouver();
    return veiculos.where((v) => v.clienteId == clienteId).toList();
  }

  @override
  Future<Veiculo> detalhar(String id) async {
    _falhaSeHouver();
    return _achar(id);
  }

  @override
  Future<Veiculo> criar(String clienteId, DadosDoVeiculo dados) async {
    _falhaSeHouver();
    criacoes.add((clienteId, dados));
    for (final v in veiculos) {
      if (v.placa == dados.placa) throw PlacaDuplicadaException(v);
    }
    final novo = Veiculo(
      id: 'novo-${veiculos.length}',
      clienteId: clienteId,
      placa: dados.placa,
      marca: dados.marca,
      modelo: dados.modelo,
      ano: dados.ano,
      cor: dados.cor,
      quilometragem: dados.quilometragem,
      ativo: true,
    );
    veiculos.add(novo);
    return novo;
  }

  @override
  Future<Veiculo> alterar(String id, DadosDoVeiculo dados) async {
    _falhaSeHouver();
    alteracoes.add((id, dados));
    final novo = _copiar(_achar(id), dados: dados);
    _substituir(novo);
    return novo;
  }

  @override
  Future<Veiculo> transferir(String id, String novoClienteId) async {
    _falhaSeHouver();
    transferencias.add((id, novoClienteId));
    final novo = _copiar(_achar(id), clienteId: novoClienteId);
    _substituir(novo);
    return novo;
  }

  @override
  Future<Veiculo> inativar(String id) async {
    _falhaSeHouver();
    inativados.add(id);
    final novo = _copiar(_achar(id), ativo: false);
    _substituir(novo);
    return novo;
  }
}
