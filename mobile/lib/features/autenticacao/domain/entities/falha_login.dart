/// Motivos pelos quais o login não conclui. Cada um tem uma mensagem própria na tela.
sealed class FalhaLogin implements Exception {
  const FalhaLogin();
}

/// E-mail ou senha incorretos. Propositalmente não diz qual dos dois.
final class CredenciaisInvalidas extends FalhaLogin {
  const CredenciaisInvalidas();
}

/// Conta válida, mas desativada pelo gerente.
final class UsuarioDesativado extends FalhaLogin {
  const UsuarioDesativado();
}

/// Conta válida, mas sem perfil cadastrado no sistema.
final class UsuarioSemPerfil extends FalhaLogin {
  const UsuarioSemPerfil();
}
