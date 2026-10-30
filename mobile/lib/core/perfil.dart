/// Perfil do usuário (RN09). Os nomes na API e no banco são `UPPER_CASE`.
enum Perfil {
  atendente,
  mecanico,
  almoxarife,
  gerente;

  String toApi() => switch (this) {
    atendente => 'ATENDENTE',
    mecanico => 'MECANICO',
    almoxarife => 'ALMOXARIFE',
    gerente => 'GERENTE',
  };

  /// Lê o perfil vindo da API; valor desconhecido é erro, nunca um perfil qualquer.
  static Perfil fromApi(String valor) {
    for (final perfil in values) {
      if (perfil.toApi() == valor) return perfil;
    }
    throw FormatException('Perfil desconhecido: $valor');
  }
}
