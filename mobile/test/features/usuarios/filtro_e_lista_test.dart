import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/core/network/api_exception.dart';
import 'package:oficina_facil/core/perfil.dart';
import 'package:oficina_facil/features/usuarios/domain/entities/usuario.dart';
import 'package:oficina_facil/features/usuarios/presentation/providers/usuarios_providers.dart';

import '../../helpers/usuarios_falso.dart';

ProviderContainer _container(UsuariosFalso fake) {
  final c = ProviderContainer(
    overrides: [usuariosRepositoryProvider.overrideWithValue(fake)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('FiltroUsuarios', () {
    test('igualdade por valor', () {
      expect(
        const FiltroUsuarios(texto: 'a', perfil: Perfil.gerente),
        const FiltroUsuarios(texto: 'a', perfil: Perfil.gerente),
      );
      expect(
        const FiltroUsuarios(texto: 'a'),
        isNot(const FiltroUsuarios(texto: 'b')),
      );
    });

    test(
      'copiarCom pode limpar o perfil e a situação (null) sem mexer no resto',
      () {
        const base = FiltroUsuarios(
          texto: 'x',
          perfil: Perfil.mecanico,
          ativo: true,
        );
        final limpo = base.copiarCom(perfil: null, ativo: null);
        expect((limpo.texto, limpo.perfil, limpo.ativo), ('x', null, null));
        expect(base.copiarCom(texto: 'y').perfil, Perfil.mecanico);
      },
    );
  });

  group('lista paginada', () {
    final cinco = [for (var i = 1; i <= 5; i++) usuario('u$i')];

    test('carrega a primeira página', () async {
      final c = _container(UsuariosFalso(cinco, tamanhoDaPagina: 2));
      final lista = await c.read(usuariosListaProvider.future);
      expect(lista.itens.map((u) => u.id), ['u1', 'u2']);
      expect((lista.total, lista.pagina, lista.temMais), (5, 1, true));
    });

    test('carregarMais acrescenta a próxima página até acabar', () async {
      final c = _container(UsuariosFalso(cinco, tamanhoDaPagina: 2));
      await c.read(usuariosListaProvider.future);
      final notifier = c.read(usuariosListaProvider.notifier);

      await notifier.carregarMais();
      await notifier.carregarMais();
      expect(c.read(usuariosListaProvider).value!.itens, hasLength(5));
      expect(c.read(usuariosListaProvider).value!.temMais, isFalse);

      await notifier.carregarMais(); // nada mais para carregar
      expect(c.read(usuariosListaProvider).value!.itens, hasLength(5));
    });

    test('mudar o filtro recomeça da primeira página', () async {
      final fake = UsuariosFalso([
        usuario('g1', perfil: Perfil.gerente),
        usuario('a1'),
        usuario('a2'),
      ], tamanhoDaPagina: 1);
      final c = _container(fake);
      await c.read(usuariosListaProvider.future);
      await c.read(usuariosListaProvider.notifier).carregarMais();

      c.read(filtroUsuariosProvider.notifier).definirPerfil(Perfil.gerente);
      final lista = await c.read(usuariosListaProvider.future);

      expect(lista.itens.map((u) => u.id), ['g1']);
      expect(lista.pagina, 1);
    });

    test(
      'falha ao carregar mais mantém o que já havia e marca a falha',
      () async {
        final fake = UsuariosFalso(cinco, tamanhoDaPagina: 2);
        final c = _container(fake);
        await c.read(usuariosListaProvider.future);

        fake.falharNaProxima = const SemConexaoException();
        await c.read(usuariosListaProvider.notifier).carregarMais();

        final lista = c.read(usuariosListaProvider).value!;
        expect(lista.itens, hasLength(2));
        expect(lista.falhouAoCarregarMais, isTrue);
        expect(lista.carregandoMais, isFalse);

        await c.read(usuariosListaProvider.notifier).carregarMais();
        expect(c.read(usuariosListaProvider).value!.itens, hasLength(4));
      },
    );

    test('falha na primeira página vira estado de erro', () async {
      final fake = UsuariosFalso(cinco)
        ..falharNaProxima = const SemConexaoException();
      final c = _container(fake);
      await expectLater(
        c.read(usuariosListaProvider.future),
        throwsA(isA<SemConexaoException>()),
      );
    });
  });
}
