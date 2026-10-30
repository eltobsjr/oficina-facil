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
