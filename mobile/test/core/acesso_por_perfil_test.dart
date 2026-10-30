import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/core/perfil.dart';
import 'package:oficina_facil/core/router/acesso_por_perfil.dart';

/// Tabela copiada do "Acesso por perfil" do Mapa de telas (vault): rota de exemplo e quem acessa.
const _atendente = Perfil.atendente;
const _mecanico = Perfil.mecanico;
const _almoxarife = Perfil.almoxarife;
const _gerente = Perfil.gerente;

final _mapa = <String, Set<Perfil>>{
  '/': {_atendente, _mecanico, _almoxarife, _gerente},
  '/usuarios': {_gerente},
  '/usuarios/novo': {_gerente},
  '/usuarios/abc-123': {_gerente},
  '/clientes': {_atendente},
  '/clientes/novo': {_atendente},
  '/clientes/abc': {_atendente},
  '/clientes/abc/veiculos': {_atendente},
  '/clientes/abc/veiculos/novo': {_atendente},
  '/servicos': {_gerente},
  '/servicos/novo': {_gerente},
  '/servicos/abc': {_gerente},
  '/pecas': {_almoxarife},
  '/pecas/novo': {_almoxarife},
  '/pecas/abc': {_almoxarife},
  '/pecas/abc/entrada': {_almoxarife},
  '/os/nova': {_atendente},
  '/os': {_atendente, _mecanico, _gerente},
  '/os/abc': {_atendente, _mecanico, _gerente},
  '/os/abc/diagnostico': {_mecanico},
  '/os/abc/orcamento': {_atendente},
  '/os/abc/aprovacao': {_atendente},
  '/os/abc/execucao': {_mecanico},
  '/os/abc/entrega': {_atendente},
  '/descontos': {_gerente},
  '/faturamento': {_gerente},
  '/notificacoes': {_atendente, _almoxarife, _gerente},
};

void main() {
  group('acesso por perfil (RN09), conforme o Mapa de telas', () {
    for (final entrada in _mapa.entries) {
      for (final perfil in Perfil.values) {
        final esperado = entrada.value.contains(perfil);
        test(
          '${perfil.name} ${esperado ? "acessa" : "NÃO acessa"} ${entrada.key}',
          () {
            expect(AcessoPorPerfil.permite(perfil, entrada.key), esperado);
          },
        );
      }
    }
  });

  test('o Mapa de telas é coberto por 27 rotas de exemplo', () {
    expect(_mapa, hasLength(27));
  });

  test(
    'rota desconhecida cai na regra geral (todos), e o 404 é do roteador',
    () {
      for (final perfil in Perfil.values) {
        expect(AcessoPorPerfil.permite(perfil, '/nao-existe'), isTrue);
      }
    },
  );

  test(
    'um prefixo parecido não vaza permissão (/usuariosx não é /usuarios)',
    () {
      expect(AcessoPorPerfil.permite(Perfil.atendente, '/usuariosx'), isTrue);
      expect(AcessoPorPerfil.permite(Perfil.atendente, '/usuarios'), isFalse);
    },
  );
}
