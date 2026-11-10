import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/core/network/api_client.dart';
import 'package:oficina_facil/features/veiculos/data/veiculos_repository_api.dart';
import 'package:oficina_facil/features/veiculos/domain/entities/veiculo.dart';

import '../../helpers/dio_falso.dart';

const _json = {
  'id': 'v1',
  'clienteId': 'c1',
  'placa': 'ABC1234',
  'marca': 'Fiat',
  'modelo': 'Uno',
  'ano': 2015,
  'cor': null,
  'quilometragem': 80000,
  'ativo': true,
};

({VeiculosRepositoryApi repo, AdaptadorFalso adaptador}) _montar(
  Map<String, RespostaFalsa> respostas,
) {
  final adaptador = AdaptadorFalso(respostas);
  final api = ApiClient(
    baseUrl: 'http://localhost:3000/api/v1',
    dio: Dio()..httpClientAdapter = adaptador,
  );
  return (repo: VeiculosRepositoryApi(api), adaptador: adaptador);
}

const _dados = DadosDoVeiculo(
  placa: 'ABC1234',
  marca: 'Fiat',
  modelo: 'Uno',
  ano: 2015,
  quilometragem: 80000,
);

void main() {
  test('doCliente pede a lista do cliente e lê os veículos', () async {
    final m = _montar({
      'GET /clientes/c1/veiculos': const RespostaFalsa(200, {
        'itens': [_json],
        'total': 1,
        'pagina': 1,
        'limite': 100,
      }),
    });
    final lista = await m.repo.doCliente('c1');
    expect(m.adaptador.chamadas.single.queryParameters, {
      'pagina': 1,
      'limite': 100,
    });
    expect(lista.single.placa, 'ABC1234');
    expect(lista.single.cor, isNull);
    expect(lista.single.quilometragem, 80000);
  });

  test('criar envia os campos ao cliente certo', () async {
    final m = _montar({
      'POST /clientes/c1/veiculos': const RespostaFalsa(201, _json),
    });
    await m.repo.criar('c1', _dados);
    expect(m.adaptador.chamadas.single.data, {
      'placa': 'ABC1234',
      'marca': 'Fiat',
      'modelo': 'Uno',
      'ano': 2015,
      'cor': null,
      'quilometragem': 80000,
    });
  });

  test(
    'placa repetida vira exceção do domínio com o veículo existente',
    () async {
      final m = _montar({
        'POST /clientes/c2/veiculos': const RespostaFalsa(409, {
          'erro': {
            'codigo': 'placa_duplicada',
            'mensagem': 'x',
            'detalhes': {'existente': _json},
          },
        }),
      });
      await expectLater(
        m.repo.criar('c2', _dados),
        throwsA(
          isA<PlacaDuplicadaException>().having(
            (e) => e.existente.clienteId,
            'dono do existente',
            'c1',
          ),
        ),
      );
    },
  );

  test(
    'alterar, transferir, inativar e detalhar chamam as rotas certas',
    () async {
      final m = _montar({
        'PATCH /veiculos/v1': const RespostaFalsa(200, _json),
        'POST /veiculos/v1/transferir': RespostaFalsa(200, {
          ..._json,
          'clienteId': 'c2',
        }),
        'POST /veiculos/v1/inativar': RespostaFalsa(200, {
          ..._json,
          'ativo': false,
        }),
        'GET /veiculos/v1': const RespostaFalsa(200, _json),
      });
      await m.repo.alterar('v1', _dados);
      final transferido = await m.repo.transferir('v1', 'c2');
      final inativo = await m.repo.inativar('v1');
      await m.repo.detalhar('v1');

      expect(m.adaptador.chamadas[1].data, {'clienteId': 'c2'});
      expect(transferido.clienteId, 'c2');
      expect(inativo.ativo, isFalse);
    },
  );
}
