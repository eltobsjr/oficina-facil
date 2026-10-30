import '../perfil.dart';

/// Nome do perfil em português, para a interface.
extension PerfilRotulo on Perfil {
  String get rotulo => switch (this) {
    Perfil.atendente => 'Atendente',
    Perfil.mecanico => 'Mecânico',
    Perfil.almoxarife => 'Almoxarife',
    Perfil.gerente => 'Gerente',
  };
}
