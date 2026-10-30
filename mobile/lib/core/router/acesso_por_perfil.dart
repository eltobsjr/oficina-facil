import '../perfil.dart';

/// Quem pode abrir cada rota (RN09). Espelha o Mapa de telas do vault; a barreira de verdade é
/// do backend, e isto só evita mostrar ao usuário o que ele não pode usar.
abstract final class AcessoPorPerfil {
  static const _todos = {
    Perfil.atendente,
    Perfil.mecanico,
    Perfil.almoxarife,
    Perfil.gerente,
  };

  /// Da regra mais específica para a mais geral: vale a primeira que casar.
  static final _regras = <(RegExp, Set<Perfil>)>[
    (RegExp(r'^/usuarios(/.*)?$'), {Perfil.gerente}),
    (RegExp(r'^/clientes(/.*)?$'), {Perfil.atendente}),
    (RegExp(r'^/servicos(/.*)?$'), {Perfil.gerente}),
    (RegExp(r'^/pecas(/.*)?$'), {Perfil.almoxarife}),
    (RegExp(r'^/os/nova$'), {Perfil.atendente}),
    (RegExp(r'^/os/[^/]+/diagnostico$'), {Perfil.mecanico}),
    (RegExp(r'^/os/[^/]+/orcamento$'), {Perfil.atendente}),
    (RegExp(r'^/os/[^/]+/aprovacao$'), {Perfil.atendente}),
    (RegExp(r'^/os/[^/]+/execucao$'), {Perfil.mecanico}),
    (RegExp(r'^/os/[^/]+/entrega$'), {Perfil.atendente}),
    (
      RegExp(r'^/os(/[^/]+)?$'),
      {Perfil.atendente, Perfil.gerente, Perfil.mecanico},
    ),
    (RegExp(r'^/descontos$'), {Perfil.gerente}),
    (RegExp(r'^/faturamento$'), {Perfil.gerente}),
    (
      RegExp(r'^/notificacoes$'),
      {Perfil.atendente, Perfil.almoxarife, Perfil.gerente},
    ),
  ];

  static bool permite(Perfil perfil, String rota) {
    for (final (padrao, perfis) in _regras) {
      if (padrao.hasMatch(rota)) return perfis.contains(perfil);
    }
    return _todos.contains(perfil);
  }
}
