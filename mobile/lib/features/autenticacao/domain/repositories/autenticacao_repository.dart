import '../entities/usuario_sessao.dart';

/// Contrato de autenticação. Falhas de login são [FalhaLogin]; falta de rede é
/// `SemConexaoException`; erros da API são `ApiException`.
abstract interface class AutenticacaoRepository {
  /// Há um token guardado no aparelho (ainda não confirmado pelo servidor).
  bool get temSessao;

  /// Muda para `false` quando a sessão acaba (saída ou renovação que falhou).
  Stream<bool> get logado;

  Future<UsuarioSessao> entrar(String email, String senha);

  /// Quem é o dono do token atual (`GET /me`).
  Future<UsuarioSessao> usuarioAtual();

  Future<void> sair();
}
