import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/core/perfil.dart';
import 'package:oficina_facil/core/router/acesso_por_perfil.dart';
import 'package:oficina_facil/core/shell/menu_por_perfil.dart';

void main() {
  group('menu por perfil', () {
    test('o gerente tem Início e Usuários', () {
      expect(menuDoPerfil(Perfil.gerente).map((i) => i.rotulo), [
        'Início',
        'Usuários',
      ]);
    });

    test('o atendente tem Início e Clientes', () {
      expect(menuDoPerfil(Perfil.atendente).map((i) => i.rotulo), [
        'Início',
        'Clientes',
      ]);
    });

    test('mecânico e almoxarife só têm Início por enquanto', () {
      for (final perfil in [Perfil.mecanico, Perfil.almoxarife]) {
        expect(menuDoPerfil(perfil).map((i) => i.rotulo), ['Início']);
      }
    });

    test('nenhum perfil vê no menu uma tela que não pode abrir', () {
      // O menu e o controle de acesso precisam concordar.
      for (final perfil in Perfil.values) {
        for (final item in menuDoPerfil(perfil)) {
          expect(
            AcessoPorPerfil.permite(perfil, item.rota),
            isTrue,
            reason: '${perfil.name} vê ${item.rotulo}',
          );
        }
      }
    });
  });

  group('item selecionado', () {
    final itens = menuDoPerfil(Perfil.gerente);

    test('Início só casa com a raiz', () {
      expect(indiceSelecionado(itens, '/'), 0);
    });

    test('Usuários casa com a lista e com as subrotas', () {
      expect(indiceSelecionado(itens, '/usuarios'), 1);
      expect(indiceSelecionado(itens, '/usuarios/novo'), 1);
      expect(indiceSelecionado(itens, '/usuarios/abc'), 1);
    });

    test('rota fora do menu seleciona o primeiro item', () {
      expect(indiceSelecionado(itens, '/outra'), 0);
    });
  });
}
