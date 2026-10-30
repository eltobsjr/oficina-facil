import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/core/network/api_exception.dart';
import 'package:oficina_facil/features/autenticacao/domain/entities/falha_login.dart';
import 'package:oficina_facil/features/autenticacao/presentation/providers/sessao_provider.dart';

import '../../helpers/autenticacao_falsa.dart';

ProviderContainer _container(AutenticacaoFalsa fake) {
  final container = ProviderContainer(
    overrides: [autenticacaoRepositoryProvider.overrideWithValue(fake)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('sem sessão guardada, ninguém está logado', () async {
    final container = _container(AutenticacaoFalsa());
    expect(await container.read(sessaoProvider.future), isNull);
  });

  test('com sessão guardada, carrega o usuário de /me', () async {
    final container = _container(
      AutenticacaoFalsa(sessaoInicial: usuarioAtendente),
    );
    expect(await container.read(sessaoProvider.future), usuarioAtendente);
  });

  test('sessão que o servidor não reconhece é encerrada', () async {
    final fake = AutenticacaoFalsa(sessaoInicial: usuarioAtendente)
      ..falhaAoCarregar = const ApiException(
        status: 401,
        codigo: 'nao_autorizado',
        mensagem: 'x',
      );
    final container = _container(fake);

    expect(await container.read(sessaoProvider.future), isNull);
    expect(fake.saidas, 1);
  });

  test(
    'sem rede ao abrir, o estado vira erro (o app oferece tentar de novo)',
    () async {
      final fake = AutenticacaoFalsa(sessaoInicial: usuarioAtendente)
        ..falhaAoCarregar = const SemConexaoException();
      final container = _container(fake);

      await expectLater(
        container.read(sessaoProvider.future),
        throwsA(isA<SemConexaoException>()),
      );
    },
  );

  test('entrar guarda o usuário na sessão', () async {
    final container = _container(
      AutenticacaoFalsa(usuarioDoLogin: usuarioGerente),
    );
    await container.read(sessaoProvider.future);

    await container.read(sessaoProvider.notifier).entrar('a@b.com', 'senha');

    expect(container.read(sessaoProvider).value, usuarioGerente);
  });

  test('falha no login sobe para a tela e não altera a sessão', () async {
    final fake = AutenticacaoFalsa()
      ..falhaAoEntrar = const CredenciaisInvalidas();
    final container = _container(fake);
    await container.read(sessaoProvider.future);

    await expectLater(
      container.read(sessaoProvider.notifier).entrar('a@b.com', 'errada'),
      throwsA(isA<CredenciaisInvalidas>()),
    );
    expect(container.read(sessaoProvider).value, isNull);
    expect(container.read(sessaoProvider).hasError, isFalse);
  });

  test('sair encerra a sessão', () async {
    final fake = AutenticacaoFalsa(sessaoInicial: usuarioGerente);
    final container = _container(fake);
    await container.read(sessaoProvider.future);

    await container.read(sessaoProvider.notifier).sair();

    expect(container.read(sessaoProvider).value, isNull);
    expect(fake.saidas, 1);
  });

  test('o fim da sessão avisado pelo Supabase derruba o usuário', () async {
    final fake = AutenticacaoFalsa(sessaoInicial: usuarioGerente);
    final container = _container(fake);
    await container.read(sessaoProvider.future);

    fake.controlador.add(false);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(sessaoProvider).value, isNull);
  });
}
