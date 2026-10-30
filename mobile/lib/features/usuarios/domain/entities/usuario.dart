import '../../../../core/perfil.dart';

/// Usuário na gestão (UC06). Nunca carrega senha.
class Usuario {
  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
    required this.ativo,
    required this.criadoEm,
  });

  final String id;
  final String nome;
  final String email;
  final Perfil perfil;
  final bool ativo;
  final DateTime criadoEm;
}

/// Uma página da lista de usuários.
class PaginaDeUsuarios {
  const PaginaDeUsuarios({
    required this.itens,
    required this.total,
    required this.pagina,
  });

  final List<Usuario> itens;
  final int total;
  final int pagina;
}

/// Busca e filtros da lista. Igualdade por valor, para o provider reagir só quando mudar de fato.
class FiltroUsuarios {
  const FiltroUsuarios({this.texto = '', this.perfil, this.ativo});

  final String texto;
  final Perfil? perfil;
  final bool? ativo;

  FiltroUsuarios copiarCom({
    String? texto,
    Object? perfil = _naoMudar,
    Object? ativo = _naoMudar,
  }) {
    return FiltroUsuarios(
      texto: texto ?? this.texto,
      perfil: identical(perfil, _naoMudar) ? this.perfil : perfil as Perfil?,
      ativo: identical(ativo, _naoMudar) ? this.ativo : ativo as bool?,
    );
  }

  static const _naoMudar = Object();

  @override
  bool operator ==(Object other) =>
      other is FiltroUsuarios &&
      other.texto == texto &&
      other.perfil == perfil &&
      other.ativo == ativo;

  @override
  int get hashCode => Object.hash(texto, perfil, ativo);
}
