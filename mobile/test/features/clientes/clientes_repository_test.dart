import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/core/network/api_client.dart';
import 'package:oficina_facil/core/network/api_exception.dart';
import 'package:oficina_facil/features/clientes/data/clientes_repository_api.dart';
import 'package:oficina_facil/features/clientes/domain/entities/cliente.dart';

import '../../helpers/dio_falso.dart';

const _json = {
  'id': 'c1',
  'nome': 'Maria Souza',
  'documento': '52998224725',
  'telefone': '11912345678',
  'email': null,
  'endereco': 'Rua Fictícia, 10',
  'ativo': true,
};

({ClientesRepositoryApi repo, AdaptadorFalso adaptador}) _montar(
  Map<String, RespostaFalsa> respostas,
) {
  final adaptador = AdaptadorFalso(respostas);
  final api = ApiClient(
    baseUrl: 'http://localhost:3000/api/v1',
    dio: Dio()..httpClientAdapter = adaptador,
  );
  return (repo: ClientesRepositoryApi(api), adaptador: adaptador);
}

const _dados = DadosDoCliente(
  nome: 'Maria Souza',
  documento: '52998224725',
  telefone: '11912345678',
);

void main() {
  test('listar manda a busca e a página, e lê a resposta', () async {
    final m = _montar({
      'GET /clientes': const RespostaFalsa(200, {
        'itens': [_json],
        'total': 41,
        'pagina': 2,
        'limite': 20,
      }),
    });

    final pagina = await m.repo.listar(' maria ', pagina: 2);

    expect(m.adaptador.chamadas.single.queryParameters, {
      'pagina': 2,
      'limite': 20,
      'q': 'maria',
    });
    expect(pagina.total, 41);
    expect(pagina.itens.single.nome, 'Maria Souza');
    expect(pagina.itens.single.email, isNull);
    expect(pagina.itens.single.endereco, 'Rua Fictícia, 10');
  });

  test('listar sem busca não manda parâmetro vazio', () async {
    final m = _montar({
      'GET /clientes': const RespostaFalsa(200, {
        'itens': <Object>[],
        'total': 0,
        'pagina': 1,
        'limite': 20,
      }),
    });
    await m.repo.listar('  ', pagina: 1);
    expect(m.adaptador.chamadas.single.queryParameters.keys, [
      'pagina',
      'limite',
    ]);
  });

  test('criar envia todos os campos, com nulos para os opcionais', () async {
    final m = _montar({'POST /clientes': const RespostaFalsa(201, _json)});
    final criado = await m.repo.criar(_dados);
    expect(m.adaptador.chamadas.single.data, {
      'nome': 'Maria Souza',
      'documento': '52998224725',
      'telefone': '11912345678',
      'email': null,
      'endereco': null,
    });
    expect(criado.id, 'c1');
  });

  test(
    'documento repetido vira exceção do domínio com o cadastro existente',
    () async {
      final m = _montar({
        'POST /clientes': const RespostaFalsa(409, {
          'erro': {
            'codigo': 'documento_duplicado',
            'mensagem': 'Já existe um cliente com este documento',
            'detalhes': {'existente': _json},
          },
        }),
      });
      await expectLater(
        m.repo.criar(_dados),
        throwsA(
          isA<DocumentoDuplicadoException>().having(
            (e) => e.existente.nome,
            'existente',
            'Maria Souza',
          ),
        ),
      );
    },
  );

  test('alterar usa PATCH e também reconhece o documento repetido', () async {
    final m = _montar({
      'PATCH /clientes/c1': const RespostaFalsa(409, {
        'erro': {
          'codigo': 'documento_duplicado',
          'mensagem': 'x',
          'detalhes': {'existente': _json},
        },
      }),
    });
    await expectLater(
      m.repo.alterar('c1', _dados),
      throwsA(isA<DocumentoDuplicadoException>()),
    );
  });

  test('detalhar e inativar chamam as rotas certas', () async {
    final m = _montar({
      'GET /clientes/c1': const RespostaFalsa(200, _json),
      'POST /clientes/c1/inativar': RespostaFalsa(200, {
        ..._json,
        'ativo': false,
      }),
    });
    expect((await m.repo.detalhar('c1')).ativo, isTrue);
    expect((await m.repo.inativar('c1')).ativo, isFalse);
  });

  test('outros erros da API sobem como ApiException com o código', () async {
    final m = _montar({
      'POST /clientes/c1/inativar': const RespostaFalsa(409, {
        'erro': {'codigo': 'cliente_com_os_ativa', 'mensagem': 'x'},
      }),
    });
    await expectLater(
      m.repo.inativar('c1'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.codigo,
          'codigo',
          'cliente_com_os_ativa',
        ),
      ),
    );
  });
}
