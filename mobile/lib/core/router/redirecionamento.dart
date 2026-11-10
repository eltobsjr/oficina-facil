import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/autenticacao/domain/entities/usuario_sessao.dart';
import 'acesso_por_perfil.dart';

abstract final class AppRoutes {
  static const inicio = '/';
  static const login = '/login';
  static const carregando = '/carregando';
  static const semConexao = '/sem-conexao';
  static const usuarios = '/usuarios';
  static const usuarioNovo = '/usuarios/novo';
  static const clientes = '/clientes';
  static const clienteNovo = '/clientes/novo';

  static String usuario(String id) => '/usuarios/$id';
  static String cliente(String id) => '/clientes/$id';
  static String veiculosDoCliente(String clienteId) =>
      '/clientes/$clienteId/veiculos';
  static String veiculoNovo(String clienteId) =>
      '/clientes/$clienteId/veiculos/novo';
  static String veiculo(String clienteId, String veiculoId) =>
      '/clientes/$clienteId/veiculos/$veiculoId';
}

/// Decide para onde mandar o usuário. Devolve `null` quando a rota atual está correta.
/// Função pura, para testar sem montar o app.
String? redirecionar(AsyncValue<UsuarioSessao?> sessao, String local) {
  if (sessao.isLoading && !sessao.hasValue) {
    return local == AppRoutes.carregando ? null : AppRoutes.carregando;
  }
  if (sessao.hasError) {
    return local == AppRoutes.semConexao ? null : AppRoutes.semConexao;
  }
  final usuario = sessao.value;
  if (usuario == null) {
    return local == AppRoutes.login ? null : AppRoutes.login;
  }
  const rotasDeEntrada = {
    AppRoutes.login,
    AppRoutes.carregando,
    AppRoutes.semConexao,
  };
  if (rotasDeEntrada.contains(local)) return AppRoutes.inicio;
  if (!AcessoPorPerfil.permite(usuario.perfil, local)) return AppRoutes.inicio;
  return null;
}
