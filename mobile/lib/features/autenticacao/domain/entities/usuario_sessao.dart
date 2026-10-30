import '../../../../core/perfil.dart';

/// Usuário autenticado: quem é e qual perfil tem (devolvido por `GET /me`).
class UsuarioSessao {
  const UsuarioSessao({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
  });

  final String id;
  final String nome;
  final String email;
  final Perfil perfil;
}
