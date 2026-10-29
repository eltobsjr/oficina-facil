/// Ciclo de vida da ordem de serviço (diagrama de estados em docs/diagramas.md).
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

  /// Cancelar é permitido em qualquer estado antes da entrega.
  bool get podeCancelar => !terminal;

  bool podeTransitarPara(StatusOrdemServico destino) {
    if (destino == cancelada) return podeCancelar;
    return proximo == destino;
  }
}
