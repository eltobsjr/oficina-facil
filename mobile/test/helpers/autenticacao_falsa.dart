import 'dart:async';

import 'package:oficina_facil/core/perfil.dart';
import 'package:oficina_facil/features/autenticacao/domain/entities/usuario_sessao.dart';
import 'package:oficina_facil/features/autenticacao/domain/repositories/autenticacao_repository.dart';

const usuarioGerente = UsuarioSessao(
  id: 'g1',
  nome: 'Gerente Um',
  email: 'gerente@teste.local',
  perfil: Perfil.gerente,
);

const usuarioAtendente = UsuarioSessao(
  id: 'a1',
  nome: 'Ana Atendente',
  email: 'ana@teste.local',
  perfil: Perfil.atendente,
);

/// Repositório de autenticação controlável pelos testes.
class AutenticacaoFalsa implements AutenticacaoRepository {
  AutenticacaoFalsa({this.sessaoInicial, this.usuarioDoLogin});

  /// Usuário já logado ao abrir o app (`null` = sem sessão).
  UsuarioSessao? sessaoInicial;

  /// Quem entra quando o login der certo.
  UsuarioSessao? usuarioDoLogin;

  /// Se definido, é lançado por `entrar`.
  Object? falhaAoEntrar;

  /// Se definido, é lançado por `usuarioAtual`.
  Object? falhaAoCarregar;

  final controlador = StreamController<bool>.broadcast();
  var saidas = 0;
  UsuarioSessao? _atual;

  @override
  bool get temSessao => sessaoInicial != null || _atual != null;

  @override
  Stream<bool> get logado => controlador.stream;

  @override
  Future<UsuarioSessao> entrar(String email, String senha) async {
    if (falhaAoEntrar != null) throw falhaAoEntrar!;
    _atual = usuarioDoLogin ?? usuarioGerente;
    return _atual!;
  }

  @override
  Future<UsuarioSessao> usuarioAtual() async {
    if (falhaAoCarregar != null) throw falhaAoCarregar!;
    return _atual ?? sessaoInicial!;
  }

  @override
  Future<void> sair() async {
    saidas++;
    sessaoInicial = null;
    _atual = null;
    controlador.add(false);
  }
}
