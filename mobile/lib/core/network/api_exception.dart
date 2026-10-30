/// Erro devolvido pela API no formato `{ "erro": { "codigo", "mensagem", "detalhes" } }`.
class ApiException implements Exception {
  const ApiException({
    required this.status,
    required this.codigo,
    required this.mensagem,
    this.detalhes,
  });

  final int status;
  final String codigo;
  final String mensagem;
  final Object? detalhes;

  /// Interpreta o corpo de uma resposta de erro; corpo fora do padrão vira erro genérico.
  factory ApiException.deResposta(int status, Object? corpo) {
    if (corpo is Map && corpo['erro'] is Map) {
      final erro = corpo['erro'] as Map;
      return ApiException(
        status: status,
        codigo: '${erro['codigo'] ?? 'erro'}',
        mensagem: '${erro['mensagem'] ?? 'Erro'}',
        detalhes: erro['detalhes'],
      );
    }
    return ApiException(
      status: status,
      codigo: 'erro',
      mensagem: 'Erro $status',
    );
  }

  @override
  String toString() => 'ApiException($status, $codigo)';
}

/// Sem resposta do servidor (rede fora do ar, timeout).
class SemConexaoException implements Exception {
  const SemConexaoException();

  @override
  String toString() => 'SemConexaoException';
}
