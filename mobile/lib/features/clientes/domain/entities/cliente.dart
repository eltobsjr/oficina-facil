/// Cliente da oficina (UC02). O documento vem só com dígitos.
class Cliente {
  const Cliente({
    required this.id,
    required this.nome,
    required this.documento,
    required this.telefone,
    required this.ativo,
    this.email,
    this.endereco,
  });

  final String id;
  final String nome;
  final String documento;
  final String telefone;
  final String? email;
  final String? endereco;
  final bool ativo;
}

/// Uma página da lista de clientes.
class PaginaDeClientes {
  const PaginaDeClientes({
    required this.itens,
    required this.total,
    required this.pagina,
  });

  final List<Cliente> itens;
  final int total;
  final int pagina;
}

/// Dados do formulário de cliente. E-mail e endereço vazios ficam `null`.
class DadosDoCliente {
  const DadosDoCliente({
    required this.nome,
    required this.documento,
    required this.telefone,
    this.email,
    this.endereco,
  });

  final String nome;
  final String documento;
  final String telefone;
  final String? email;
  final String? endereco;
}

/// O documento já pertence a outro cliente; [existente] é o cadastro que o usa.
class DocumentoDuplicadoException implements Exception {
  const DocumentoDuplicadoException(this.existente);

  final Cliente existente;

  @override
  String toString() => 'DocumentoDuplicadoException(${existente.id})';
}
