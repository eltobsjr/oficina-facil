import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/features/ordem_servico/domain/entities/status_ordem_servico.dart';

void main() {
  group('StatusOrdemServico', () {
    test('percorre o fluxo principal até a entrega', () {
      var status = StatusOrdemServico.aberta;
      final percorridos = [status];
      while (status.proximo != null) {
        status = status.proximo!;
        percorridos.add(status);
      }

      expect(percorridos, [
        StatusOrdemServico.aberta,
        StatusOrdemServico.diagnosticada,
        StatusOrdemServico.aguardandoAprovacao,
        StatusOrdemServico.aprovada,
        StatusOrdemServico.emExecucao,
        StatusOrdemServico.concluida,
        StatusOrdemServico.entregue,
      ]);
    });

    test('não permite pular etapas', () {
      expect(
        StatusOrdemServico.aberta.podeTransitarPara(
          StatusOrdemServico.emExecucao,
        ),
        isFalse,
      );
    });

    test('cancela em qualquer estado antes da entrega', () {
      final cancelaveis = StatusOrdemServico.values.where(
        (s) => s.podeCancelar,
      );

      expect(cancelaveis, isNot(contains(StatusOrdemServico.entregue)));
      expect(cancelaveis, isNot(contains(StatusOrdemServico.cancelada)));
      expect(cancelaveis, hasLength(6));
    });

    test('estados terminais não avançam', () {
      expect(StatusOrdemServico.entregue.proximo, isNull);
      expect(StatusOrdemServico.cancelada.proximo, isNull);
    });
  });
}
