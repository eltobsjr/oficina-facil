import '../../../../core/perfil.dart';
import '../entities/usuario.dart';

/// Gestão de usuários (só o gerente). Erros da API sobem como `ApiException`.
abstract interface class UsuariosRepository {
  Future<PaginaDeUsuarios> listar(FiltroUsuarios filtro, {required int pagina});

  Future<Usuario> detalhar(String id);

  Future<Usuario> criar({
    required String nome,
    required String email,
    required Perfil perfil,
    required String senha,
  });

  Future<Usuario> alterar(String id, {String? nome, Perfil? perfil});

  Future<void> redefinirSenha(String id, String senha);

  Future<Usuario> inativar(String id);

  Future<Usuario> ativar(String id);
}
