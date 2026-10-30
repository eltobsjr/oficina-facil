import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/autenticacao/presentation/pages/login_page.dart';
import '../../features/autenticacao/presentation/pages/paginas_de_sessao.dart';
import '../../features/autenticacao/presentation/providers/sessao_provider.dart';
import '../../features/inicio/presentation/pages/inicio_page.dart';
import '../../features/usuarios/presentation/pages/usuario_form_page.dart';
import '../../features/usuarios/presentation/pages/usuarios_page.dart';
import '../shell/app_shell.dart';
import 'redirecionamento.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // O roteador reavalia o redirecionamento sempre que a sessão muda.
  final atualizacao = ValueNotifier<int>(0);
  ref.listen(sessaoProvider, (_, _) => atualizacao.value++);

  final roteador = GoRouter(
    initialLocation: AppRoutes.inicio,
    refreshListenable: atualizacao,
    redirect: (context, state) =>
        redirecionar(ref.read(sessaoProvider), state.matchedLocation),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.carregando,
        builder: (context, state) => const CarregandoSessaoPage(),
      ),
      GoRoute(
        path: AppRoutes.semConexao,
        builder: (context, state) => const SemConexaoPage(),
      ),
      ShellRoute(
        builder: (context, state, filho) => AppShell(filho: filho),
        routes: [
          GoRoute(
            path: AppRoutes.inicio,
            builder: (context, state) => const InicioPage(),
          ),
          GoRoute(
            path: AppRoutes.usuarios,
            builder: (context, state) => const UsuariosPage(),
            routes: [
              // `novo` vem antes de `:id`, senão "novo" seria lido como um id.
              GoRoute(
                path: 'novo',
                builder: (context, state) => const UsuarioFormPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    UsuarioFormPage(usuarioId: state.pathParameters['id']),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    roteador.dispose();
    atualizacao.dispose();
  });
  return roteador;
});
