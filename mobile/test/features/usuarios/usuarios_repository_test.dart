import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/core/network/api_client.dart';
import 'package:oficina_facil/core/network/api_exception.dart';
import 'package:oficina_facil/core/perfil.dart';
import 'package:oficina_facil/features/usuarios/data/usuarios_repository_api.dart';
import 'package:oficina_facil/features/usuarios/domain/entities/usuario.dart';

import '../../helpers/dio_falso.dart';

const _json = {
  'id': 'u1',
  'nome': 'Ana',
  'email': 'ana@teste.local',
  'perfil': 'MECANICO',
  'ativo': true,
  'criadoEm': '2026-11-02T12:00:00.000Z',
};

({UsuariosRepositoryApi repo, AdaptadorFalso adaptador}) _montar(
  Map<String, RespostaFalsa> respostas,
) {
  final adaptador = AdaptadorFalso(respostas);
  final api = ApiClient(
    baseUrl: 'http://localhost:3000/api/v1',
    dio: Dio()..httpClientAdapter = adaptador,
  );
  return (repo: UsuariosRepositoryApi(api), adaptador: adaptador);
}

void main() {
  test('listar manda busca, filtros e página, e lê a resposta', () async {
    final m = _montar({
      'GET /usuarios': const RespostaFalsa(200, {
        'itens': [_json],
        'total': 41,
        'pagina': 2,
        'limite': 20,
      }),
    });

    final pagina = await m.repo.listar(
      const FiltroUsuarios(
        texto: ' ana ',
        perfil: Perfil.mecanico,
        ativo: false,
      ),
      pagina: 2,
    );

    final consulta = m.adaptador.chamadas.single.queryParameters;
    expect(consulta, {
      'pagina': 2,
      'limite': 20,
      'q': 'ana',
      'perfil': 'MECANICO',
      'ativo': 'false',
    });
    expect(pagina.total, 41);
    expect(pagina.pagina, 2);
    expect(pagina.itens.single.perfil, Perfil.mecanico);
    expect(pagina.itens.single.criadoEm.toUtc().year, 2026);
  });

  test('listar sem filtros não manda parâmetros vazios', () async {
    final m = _montar({
      'GET /usuarios': const RespostaFalsa(200, {
        'itens': <Object>[],
        'total': 0,
        'pagina': 1,
        'limite': 20,
      }),
    });
    await m.repo.listar(const FiltroUsuarios(), pagina: 1);
    expect(m.adaptador.chamadas.single.queryParameters.keys, [
      'pagina',
      'limite',
    ]);
  });

  test('criar envia os quatro campos e devolve o usuário sem senha', () async {
    final m = _montar({'POST /usuarios': const RespostaFalsa(201, _json)});
    final criado = await m.repo.criar(
      nome: 'Ana',
      email: 'ana@teste.local',
      perfil: Perfil.mecanico,
      senha: 'senha-forte-1',
    );
    expect(m.adaptador.chamadas.single.data, {
      'nome': 'Ana',
      'email': 'ana@teste.local',
      'perfil': 'MECANICO',
      'senha': 'senha-forte-1',
    });
    expect(criado.nome, 'Ana');
  });

  test('alterar envia só o que mudou', () async {
    final m = _montar({'PATCH /usuarios/u1': const RespostaFalsa(200, _json)});
    await m.repo.alterar('u1', nome: 'Ana Souza');
    expect(m.adaptador.chamadas.single.data, {'nome': 'Ana Souza'});
    await m.repo.alterar('u1', perfil: Perfil.gerente);
    expect(m.adaptador.chamadas.last.data, {'perfil': 'GERENTE'});
  });

  test('redefinir senha, inativar e ativar chamam as rotas certas', () async {
    final m = _montar({
      'POST /usuarios/u1/redefinir-senha': const RespostaFalsa(204),
      'POST /usuarios/u1/inativar': const RespostaFalsa(200, _json),
      'POST /usuarios/u1/ativar': const RespostaFalsa(200, _json),
    });
    await m.repo.redefinirSenha('u1', 'nova-senha-9');
    await m.repo.inativar('u1');
    await m.repo.ativar('u1');
    expect(m.adaptador.chamadas.map((c) => c.path), [
      '/usuarios/u1/redefinir-senha',
      '/usuarios/u1/inativar',
      '/usuarios/u1/ativar',
    ]);
    expect(m.adaptador.chamadas.first.data, {'senha': 'nova-senha-9'});
  });

  test('erro da API sobe como ApiException com o código', () async {
    final m = _montar({
      'POST /usuarios/u1/inativar': const RespostaFalsa(409, {
        'erro': {'codigo': 'ultimo_gerente', 'mensagem': 'x'},
      }),
    });
    await expectLater(
      m.repo.inativar('u1'),
      throwsA(
        isA<ApiException>().having((e) => e.codigo, 'codigo', 'ultimo_gerente'),
      ),
    );
  });
}
