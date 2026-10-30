import 'package:oficina_facil/core/network/api_exception.dart';
import 'package:oficina_facil/core/perfil.dart';
import 'package:oficina_facil/features/usuarios/domain/entities/usuario.dart';
import 'package:oficina_facil/features/usuarios/domain/repositories/usuarios_repository.dart';

Usuario usuario(
  String id, {
  String? nome,
  Perfil perfil = Perfil.atendente,
  bool ativo = true,
}) => Usuario(
  id: id,
  nome: nome ?? 'Pessoa $id',
  email: '$id@teste.local',
  perfil: perfil,
  ativo: ativo,
  criadoEm: DateTime(2026, 11, 2),
);

/// Repositório de usuários em memória, com registro das chamadas e falhas injetáveis.
class UsuariosFalso implements UsuariosRepository {
  UsuariosFalso(List<Usuario> iniciais, {this.tamanhoDaPagina = 20})
    : usuarios = [...iniciais];

  final List<Usuario> usuarios;
  final int tamanhoDaPagina;

  /// Falha lançada pela próxima operação (e só por ela).
  Object? falharNaProxima;

  final listagens = <(FiltroUsuarios, int)>[];
  final criacoes = <Map<String, Object?>>[];
  final alteracoes = <Map<String, Object?>>[];
  final senhas = <String>[];
  final inativados = <String>[];
  final ativados = <String>[];

  void _falhaSeHouver() {
    final falha = falharNaProxima;
    if (falha != null) {
      falharNaProxima = null;
      throw falha;
    }
  }

  @override
  Future<PaginaDeUsuarios> listar(
    FiltroUsuarios filtro, {
    required int pagina,
  }) async {
    listagens.add((filtro, pagina));
    _falhaSeHouver();
    final texto = filtro.texto.toLowerCase();
    final filtrados = usuarios
        .where((u) => filtro.perfil == null || u.perfil == filtro.perfil)
        .where((u) => filtro.ativo == null || u.ativo == filtro.ativo)
        .where(
          (u) =>
              texto.isEmpty ||
              u.nome.toLowerCase().contains(texto) ||
              u.email.contains(texto),
        )
        .toList();
    final inicio = (pagina - 1) * tamanhoDaPagina;
    return PaginaDeUsuarios(
      itens: filtrados.skip(inicio).take(tamanhoDaPagina).toList(),
      total: filtrados.length,
      pagina: pagina,
    );
  }

  Usuario _achar(String id) => usuarios.firstWhere(
    (u) => u.id == id,
    orElse: () => throw const ApiException(
      status: 404,
      codigo: 'nao_encontrado',
      mensagem: 'Usuário não encontrado',
    ),
  );

  @override
  Future<Usuario> detalhar(String id) async {
    _falhaSeHouver();
    return _achar(id);
  }

  @override
  Future<Usuario> criar({
    required String nome,
    required String email,
    required Perfil perfil,
    required String senha,
  }) async {
    _falhaSeHouver();
    criacoes.add({
      'nome': nome,
      'email': email,
      'perfil': perfil,
      'senha': senha,
    });
    final novo = Usuario(
      id: 'novo-${usuarios.length}',
      nome: nome,
      email: email,
      perfil: perfil,
      ativo: true,
      criadoEm: DateTime(2026, 11, 3),
    );
    usuarios.add(novo);
    return novo;
  }

  void _substituir(Usuario novo) {
    final i = usuarios.indexWhere((u) => u.id == novo.id);
    usuarios[i] = novo;
  }

  @override
  Future<Usuario> alterar(String id, {String? nome, Perfil? perfil}) async {
    _falhaSeHouver();
    alteracoes.add({'id': id, 'nome': nome, 'perfil': perfil});
    final atual = _achar(id);
    final novo = Usuario(
      id: atual.id,
      nome: nome ?? atual.nome,
      email: atual.email,
      perfil: perfil ?? atual.perfil,
      ativo: atual.ativo,
      criadoEm: atual.criadoEm,
    );
    _substituir(novo);
    return novo;
  }

  @override
  Future<void> redefinirSenha(String id, String senha) async {
    _falhaSeHouver();
    senhas.add(senha);
  }

  Usuario _situacao(String id, {required bool ativo}) {
    final atual = _achar(id);
    final novo = Usuario(
      id: atual.id,
      nome: atual.nome,
      email: atual.email,
      perfil: atual.perfil,
      ativo: ativo,
      criadoEm: atual.criadoEm,
    );
    _substituir(novo);
    return novo;
  }

  @override
  Future<Usuario> inativar(String id) async {
    _falhaSeHouver();
    inativados.add(id);
    return _situacao(id, ativo: false);
  }

  @override
  Future<Usuario> ativar(String id) async {
    _falhaSeHouver();
    ativados.add(id);
    return _situacao(id, ativo: true);
  }
}
