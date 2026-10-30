import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/perfil.dart';
import '../domain/entities/falha_login.dart';
import '../domain/entities/usuario_sessao.dart';
import '../domain/repositories/autenticacao_repository.dart';
import 'provedor_de_sessao.dart';

class AutenticacaoRepositoryApi implements AutenticacaoRepository {
  AutenticacaoRepositoryApi(this._sessao, this._api);

  final ProvedorDeSessao _sessao;
  final ApiClient _api;

  @override
  bool get temSessao => _sessao.temSessao;

  @override
  Stream<bool> get logado => _sessao.logado;

  @override
  Future<UsuarioSessao> entrar(String email, String senha) async {
    await _sessao.entrar(email, senha);
    try {
      return await usuarioAtual();
    } on ApiException catch (erro) {
      // O Supabase aceitou a senha, mas o sistema não deixa entrar: desfaz a sessão.
      await _sessao.sair();
      throw switch (erro.codigo) {
        'usuario_inativo' => const UsuarioDesativado(),
        'usuario_sem_perfil' => const UsuarioSemPerfil(),
        _ => erro,
      };
    }
  }

  @override
  Future<UsuarioSessao> usuarioAtual() async {
    final corpo = await _api.chamar('GET', '/me') as Map<String, dynamic>;
    return UsuarioSessao(
      id: corpo['id'] as String,
      nome: corpo['nome'] as String,
      email: corpo['email'] as String,
      perfil: Perfil.fromApi(corpo['perfil'] as String),
    );
  }

  @override
  Future<void> sair() => _sessao.sair();
}
