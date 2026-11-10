/// Veículo de um cliente (UC03). A placa vem normalizada (maiúsculas, sem hífen).
class Veiculo {
  const Veiculo({
    required this.id,
    required this.clienteId,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.quilometragem,
    required this.ativo,
    this.cor,
  });

  final String id;
  final String clienteId;
  final String placa;
  final String marca;
  final String modelo;
  final int ano;
  final String? cor;
  final int quilometragem;
  final bool ativo;
}

/// Dados do formulário de veículo. Cor vazia fica `null`.
class DadosDoVeiculo {
  const DadosDoVeiculo({
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.quilometragem,
    this.cor,
  });

  final String placa;
  final String marca;
  final String modelo;
  final int ano;
  final String? cor;
  final int quilometragem;
}

/// A placa já pertence a outro veículo; [existente] é o cadastro que a usa.
class PlacaDuplicadaException implements Exception {
  const PlacaDuplicadaException(this.existente);

  final Veiculo existente;

  @override
  String toString() => 'PlacaDuplicadaException(${existente.id})';
}
