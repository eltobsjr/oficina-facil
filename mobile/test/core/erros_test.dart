import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/core/erro/mensagem_de_erro.dart';
import 'package:oficina_facil/core/network/api_exception.dart';
import 'package:oficina_facil/core/perfil.dart';

ApiException _erro(
  int status,
  String codigo, [
  String mensagem = 'msg da api',
]) => ApiException(status: status, codigo: codigo, mensagem: mensagem);

void main() {
  group('ApiException.deResposta', () {
    test('lê o formato padrão de erro da API', () {
      final e = ApiException.deResposta(409, {
        'erro': {'codigo': 'conflito', 'mensagem': 'E-mail já cadastrado'},
      });
      expect(
        (e.status, e.codigo, e.mensagem),
        (409, 'conflito', 'E-mail já cadastrado'),
      );
    });

    test('corpo fora do padrão vira erro genérico, sem quebrar', () {
      for (final corpo in [
        null,
        'texto',
        <String, dynamic>{},
        {'erro': 'x'},
      ]) {
        final e = ApiException.deResposta(502, corpo);
        expect((e.status, e.codigo), (502, 'erro'));
      }
    });
  });

  group('mensagem para o usuário', () {
    test('rede fora do ar', () {
      expect(
        mensagemDeErro(const SemConexaoException()),
        contains('Sem conexão'),
      );
    });

    test('códigos conhecidos viram texto claro, sem código interno', () {
      expect(
        mensagemDeErro(_erro(403, 'usuario_inativo')),
        contains('desativado'),
      );
      expect(
        mensagemDeErro(_erro(403, 'usuario_sem_perfil')),
        contains('perfil'),
      );
      expect(
        mensagemDeErro(_erro(409, 'ultimo_gerente')),
        contains('último gerente'),
      );
      expect(
        mensagemDeErro(_erro(422, 'validacao')),
        contains('não são válidos'),
      );
      expect(
        mensagemDeErro(_erro(401, 'nao_autorizado')),
        contains('sessão expirou'),
      );
      expect(
        mensagemDeErro(_erro(429, 'limite_de_taxa')),
        contains('Muitas tentativas'),
      );
    });

    test('conflito usa a mensagem da API (já é em português)', () {
      expect(
        mensagemDeErro(_erro(409, 'conflito', 'E-mail já cadastrado')),
        'E-mail já cadastrado',
      );
    });

    test('erro de servidor e erro desconhecido têm texto próprio', () {
      expect(
        mensagemDeErro(_erro(500, 'erro_interno')),
        contains('servidor teve um problema'),
      );
      expect(
        mensagemDeErro(_erro(400, 'qualquer')),
        contains('Não foi possível'),
      );
      expect(mensagemDeErro(StateError('x')), contains('Algo deu errado'));
    });

    test('nunca expõe o código interno nem o status', () {
      for (final e in [
        _erro(409, 'ultimo_gerente'),
        _erro(500, 'erro_interno'),
        _erro(403, 'usuario_inativo'),
      ]) {
        expect(mensagemDeErro(e), isNot(contains(e.codigo)));
      }
    });
  });

  group('Perfil', () {
    test('toApi e fromApi são inversos para os 4 perfis', () {
      for (final p in Perfil.values) {
        expect(Perfil.fromApi(p.toApi()), p);
      }
    });

    test('valor desconhecido é erro', () {
      expect(() => Perfil.fromApi('DONO'), throwsFormatException);
      expect(() => Perfil.fromApi('gerente'), throwsFormatException);
    });
  });
}
