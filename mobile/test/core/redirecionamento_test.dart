import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/core/router/redirecionamento.dart';
import 'package:oficina_facil/features/autenticacao/domain/entities/usuario_sessao.dart';

import '../helpers/autenticacao_falsa.dart';

AsyncValue<UsuarioSessao?> _com(UsuarioSessao? usuario) => AsyncData(usuario);

void main() {
  group('sem sessão', () {
    test('qualquer rota vai para o login', () {
      expect(redirecionar(_com(null), '/'), AppRoutes.login);
      expect(redirecionar(_com(null), '/usuarios'), AppRoutes.login);
    });

    test('quem já está no login fica nele', () {
      expect(redirecionar(_com(null), AppRoutes.login), isNull);
    });
  });

  group('confirmando a sessão', () {
    test('carregando manda para a tela de espera', () {
      expect(
        redirecionar(const AsyncLoading(), '/usuarios'),
        AppRoutes.carregando,
      );
      expect(redirecionar(const AsyncLoading(), AppRoutes.carregando), isNull);
    });

    test('erro de rede manda para a tela de nova tentativa', () {
      final erro = AsyncError<UsuarioSessao?>('x', StackTrace.empty);
      expect(redirecionar(erro, '/'), AppRoutes.semConexao);
      expect(redirecionar(erro, AppRoutes.semConexao), isNull);
    });
  });

  group('com sessão', () {
    test('sai das telas de entrada para o início', () {
      for (final rota in [
        AppRoutes.login,
        AppRoutes.carregando,
        AppRoutes.semConexao,
      ]) {
        expect(redirecionar(_com(usuarioGerente), rota), AppRoutes.inicio);
      }
    });

    test('o gerente abre a lista de usuários', () {
      expect(redirecionar(_com(usuarioGerente), '/usuarios'), isNull);
      expect(redirecionar(_com(usuarioGerente), '/usuarios/novo'), isNull);
    });

    test('o atendente é mandado ao início se tentar abrir usuários', () {
      expect(
        redirecionar(_com(usuarioAtendente), '/usuarios'),
        AppRoutes.inicio,
      );
      expect(
        redirecionar(_com(usuarioAtendente), '/usuarios/abc'),
        AppRoutes.inicio,
      );
    });

    test('o início é de todos', () {
      expect(redirecionar(_com(usuarioAtendente), '/'), isNull);
    });
  });
}
