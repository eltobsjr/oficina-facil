import '../../../ordem_servico/domain/entities/status_ordem_servico.dart';

extension StatusOrdemServicoLabel on StatusOrdemServico {
  String get rotulo => switch (this) {
    StatusOrdemServico.aberta => 'Aberta',
    StatusOrdemServico.diagnosticada => 'Diagnosticada',
    StatusOrdemServico.aguardandoAprovacao => 'Aguardando aprovação',
    StatusOrdemServico.aprovada => 'Aprovada',
    StatusOrdemServico.emExecucao => 'Em execução',
    StatusOrdemServico.concluida => 'Concluída',
    StatusOrdemServico.entregue => 'Entregue',
    StatusOrdemServico.cancelada => 'Cancelada',
  };
}
