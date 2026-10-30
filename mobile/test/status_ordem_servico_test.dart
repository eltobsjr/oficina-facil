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

    test(
      'tabela completa de transições: só o próximo estado e o cancelamento',
      () {
        for (final origem in StatusOrdemServico.values) {
          for (final destino in StatusOrdemServico.values) {
            final esperado = destino == StatusOrdemServico.cancelada
                ? !origem.terminal
                : origem.proximo == destino;
            expect(
              origem.podeTransitarPara(destino),
              esperado,
              reason: '$origem -> $destino',
            );
          }
        }
      },
    );

    test('não permite pular etapas', () {
      expect(
        StatusOrdemServico.aberta.podeTransitarPara(
          StatusOrdemServico.emExecucao,
        ),
        isFalse,
      );
    });

    test('cancela exatamente nos 6 estados anteriores à entrega', () {
      final cancelaveis = StatusOrdemServico.values.where(
        (s) => s.podeTransitarPara(StatusOrdemServico.cancelada),
      );

      expect(cancelaveis, [
        StatusOrdemServico.aberta,
        StatusOrdemServico.diagnosticada,
        StatusOrdemServico.aguardandoAprovacao,
        StatusOrdemServico.aprovada,
        StatusOrdemServico.emExecucao,
        StatusOrdemServico.concluida,
      ]);
    });

    test('estados terminais não avançam nem cancelam', () {
      for (final terminal in [
        StatusOrdemServico.entregue,
        StatusOrdemServico.cancelada,
      ]) {
        expect(terminal.terminal, isTrue);
        expect(terminal.proximo, isNull);
        expect(
          terminal.podeTransitarPara(StatusOrdemServico.cancelada),
          isFalse,
        );
      }
    });
  });
}
