import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/autenticacao_repository_api.dart';
import '../../data/provedor_de_sessao.dart';
import '../../domain/entities/usuario_sessao.dart';
import '../../domain/repositories/autenticacao_repository.dart';

final autenticacaoRepositoryProvider = Provider<AutenticacaoRepository>((ref) {
  return AutenticacaoRepositoryApi(
    SupabaseProvedorDeSessao(Supabase.instance.client.auth),
    ref.watch(apiClientProvider),
  );
});

/// Quem está logado: `null` sem sessão. Enquanto carrega, o roteador mostra a tela de espera.
class SessaoNotifier extends AsyncNotifier<UsuarioSessao?> {
  @override
  Future<UsuarioSessao?> build() async {
    final repo = ref.watch(autenticacaoRepositoryProvider);
    final assinatura = repo.logado.listen((logado) {
      if (!logado) state = const AsyncData(null);
    });
    ref.onDispose(assinatura.cancel);

    if (!repo.temSessao) return null;
    try {
      return await repo.usuarioAtual();
    } on ApiException {
      // O servidor não reconhece mais esta sessão (expirada, usuário desativado).
      await repo.sair();
      return null;
    }
  }

  /// Falhas ([FalhaLogin], rede, API) sobem para a tela de login mostrar.
  Future<void> entrar(String email, String senha) async {
    final usuario = await ref
        .read(autenticacaoRepositoryProvider)
        .entrar(email, senha);
    state = AsyncData(usuario);
  }

  Future<void> sair() async {
    await ref.read(autenticacaoRepositoryProvider).sair();
    state = const AsyncData(null);
  }
}

final sessaoProvider = AsyncNotifierProvider<SessaoNotifier, UsuarioSessao?>(
  SessaoNotifier.new,
  // Sem repetição automática: quem decide tentar de novo é o usuário, na tela.
  retry: (_, _) => null,
);
