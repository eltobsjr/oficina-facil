import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/core/network/api_client.dart';
import 'package:oficina_facil/core/network/api_exception.dart';
import 'package:oficina_facil/core/perfil.dart';
import 'package:oficina_facil/features/autenticacao/data/autenticacao_repository_api.dart';
import 'package:oficina_facil/features/autenticacao/data/provedor_de_sessao.dart';
import 'package:oficina_facil/features/autenticacao/domain/entities/falha_login.dart';

import '../../helpers/dio_falso.dart';

class _ProvedorFalso implements ProvedorDeSessao {
  Object? falhaAoEntrar;
  var saidas = 0;
  var entradas = 0;

  @override
  bool get temSessao => true;

  @override
  Stream<bool> get logado => const Stream.empty();

  @override
  Future<void> entrar(String email, String senha) async {
    entradas++;
    if (falhaAoEntrar != null) throw falhaAoEntrar!;
  }

  @override
  Future<void> sair() async => saidas++;
}

Map<String, dynamic> _usuario(String perfil) => {
  'id': 'u1',
  'nome': 'Fulana',
  'email': 'fulana@teste.local',
  'perfil': perfil,
};

({AutenticacaoRepositoryApi repo, _ProvedorFalso provedor}) _montar(
  Map<String, RespostaFalsa> respostas, {
  bool semRede = false,
}) {
  final provedor = _ProvedorFalso();
  final api = ApiClient(
    baseUrl: 'http://localhost:3000/api/v1',
    dio: Dio()..httpClientAdapter = AdaptadorFalso(respostas, semRede: semRede),
  );
  return (repo: AutenticacaoRepositoryApi(provedor, api), provedor: provedor);
}

void main() {
  group('entrar', () {
    test('devolve o usuário e o perfil lidos de /me', () async {
      final m = _montar({'GET /me': RespostaFalsa(200, _usuario('MECANICO'))});
      final usuario = await m.repo.entrar('a@b.com', 'senha');
      expect(usuario.nome, 'Fulana');
      expect(usuario.perfil, Perfil.mecanico);
      expect(m.provedor.saidas, 0);
    });

    test(
      'usuário desativado: desfaz a sessão e lança UsuarioDesativado',
      () async {
        final m = _montar({
          'GET /me': const RespostaFalsa(403, {
            'erro': {
              'codigo': 'usuario_inativo',
              'mensagem': 'Usuário inativo',
            },
          }),
        });
        await expectLater(
          m.repo.entrar('a@b.com', 'senha'),
          throwsA(isA<UsuarioDesativado>()),
        );
        expect(m.provedor.saidas, 1, reason: 'não pode ficar logado');
      },
    );

    test(
      'usuário sem perfil: desfaz a sessão e lança UsuarioSemPerfil',
      () async {
        final m = _montar({
          'GET /me': const RespostaFalsa(403, {
            'erro': {'codigo': 'usuario_sem_perfil', 'mensagem': 'x'},
          }),
        });
        await expectLater(
          m.repo.entrar('a@b.com', 'senha'),
          throwsA(isA<UsuarioSemPerfil>()),
        );
        expect(m.provedor.saidas, 1);
      },
    );

    test('credencial errada não chega a chamar /me', () async {
      final m = _montar({});
      m.provedor.falhaAoEntrar = const CredenciaisInvalidas();
      await expectLater(
        m.repo.entrar('a@b.com', 'errada'),
        throwsA(isA<CredenciaisInvalidas>()),
      );
    });

    test(
      'erro do servidor em /me continua sendo ApiException (e desfaz a sessão)',
      () async {
        final m = _montar({
          'GET /me': const RespostaFalsa(500, {
            'erro': {'codigo': 'erro_interno', 'mensagem': 'x'},
          }),
        });
        await expectLater(
          m.repo.entrar('a@b.com', 'senha'),
          throwsA(isA<ApiException>().having((e) => e.status, 'status', 500)),
        );
        expect(m.provedor.saidas, 1);
      },
    );
  });

  group('usuarioAtual', () {
    test('lê os quatro perfis', () async {
      for (final p in ['ATENDENTE', 'MECANICO', 'ALMOXARIFE', 'GERENTE']) {
        final m = _montar({'GET /me': RespostaFalsa(200, _usuario(p))});
        expect((await m.repo.usuarioAtual()).perfil.toApi(), p);
      }
    });

    test('perfil desconhecido da API é erro, não um perfil qualquer', () async {
      final m = _montar({'GET /me': RespostaFalsa(200, _usuario('DONO'))});
      await expectLater(m.repo.usuarioAtual(), throwsFormatException);
    });

    test('sem rede lança SemConexaoException', () async {
      final m = _montar({}, semRede: true);
      await expectLater(
        m.repo.usuarioAtual(),
        throwsA(isA<SemConexaoException>()),
      );
    });
  });

  test('sair repassa ao provedor', () async {
    final m = _montar({});
    await m.repo.sair();
    expect(m.provedor.saidas, 1);
  });
}
