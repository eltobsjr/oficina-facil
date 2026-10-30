/// Ciclo de vida da ordem de serviço (vault: Casos de uso, seção 5).
enum StatusOrdemServico {
  aberta,
  diagnosticada,
  aguardandoAprovacao,
  aprovada,
  emExecucao,
  concluida,
  entregue,
  cancelada;

  /// Valor do estado na API e no banco (`UPPER_SNAKE`). Único lugar da conversão.
  String toApi() => switch (this) {
    aberta => 'ABERTA',
    diagnosticada => 'DIAGNOSTICADA',
    aguardandoAprovacao => 'AGUARDANDO_APROVACAO',
    aprovada => 'APROVADA',
    emExecucao => 'EM_EXECUCAO',
    concluida => 'CONCLUIDA',
    entregue => 'ENTREGUE',
    cancelada => 'CANCELADA',
  };

  /// Lê o estado vindo da API; valor desconhecido é erro, nunca um estado qualquer.
  static StatusOrdemServico fromApi(String valor) {
    for (final estado in values) {
      if (estado.toApi() == valor) return estado;
    }
    throw FormatException('Estado de OS desconhecido: $valor');
  }

  /// Próximo estado do fluxo principal; `null` em estados terminais.
  /// A recusa do cliente (-> [cancelada]) é tratada em [podeTransitarPara].
  StatusOrdemServico? get proximo => switch (this) {
    aberta => diagnosticada,
    diagnosticada => aguardandoAprovacao,
    aguardandoAprovacao => aprovada,
    aprovada => emExecucao,
    emExecucao => concluida,
    concluida => entregue,
    entregue || cancelada => null,
  };

  bool get terminal => this == entregue || this == cancelada;

  bool podeTransitarPara(StatusOrdemServico destino) {
    if (destino == cancelada) return !terminal;
    return proximo == destino;
  }
}
