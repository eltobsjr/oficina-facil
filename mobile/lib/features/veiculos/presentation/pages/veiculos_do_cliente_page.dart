import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/erro/mensagem_de_erro.dart';
import '../../../../core/formatacao/contato.dart';
import '../../../../core/router/redirecionamento.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/estados.dart';
import '../../../../core/widgets/largura_maxima.dart';
import '../../../../core/widgets/tela_com_sub_barra.dart';
import '../../../../core/widgets/tile_escuro.dart';
import '../../../clientes/presentation/providers/clientes_providers.dart';
import '../providers/veiculos_providers.dart';
import '../widgets/veiculo_tile.dart';

/// T07 (lista): veículos de um cliente, com acesso ao formulário de veículo.
class VeiculosDoClientePage extends ConsumerWidget {
  const VeiculosDoClientePage({super.key, required this.clienteId});

  final String clienteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dono = ref.watch(clienteDetalheProvider(clienteId)).value;
    final veiculos = ref.watch(veiculosDoClienteProvider(clienteId));

    return TelaComSubBarra(
      titulo: 'Veículos',
      aoVoltar: () => context.go(AppRoutes.cliente(clienteId)),
      rotuloVoltar: 'Voltar para o cliente',
      rotuloAcao: 'Novo veículo',
      aoAcionar: () => context.go(AppRoutes.veiculoNovo(clienteId)),
      filho: Column(
        children: [
          if (dono != null)
            TileEscuro(
              legenda: 'Cliente',
              titulo: dono.nome,
              apoio: contatoFormatado(dono.documento, dono.telefone),
              acao: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.acaoSobreEscuro,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(44, 44),
                  ),
                  onPressed: () => context.go(AppRoutes.cliente(clienteId)),
                  child: const Text('Editar cadastro'),
                ),
              ),
            ),
          Expanded(
            child: LarguraMaxima(
              child: veiculos.when(
                loading: () => const Carregando(),
                error: (erro, _) => EstadoErro(
                  mensagem: mensagemDeErro(erro),
                  aoTentarDeNovo: () =>
                      ref.invalidate(veiculosDoClienteProvider(clienteId)),
                ),
                data: (itens) {
                  if (itens.isEmpty) {
                    return const EstadoVazio(
                      mensagem: 'Este cliente ainda não tem veículos.',
                      icone: Icons.directions_car_outlined,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(
                      veiculosDoClienteProvider(clienteId).future,
                    ),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      itemCount: itens.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, indice) {
                        final veiculo = itens[indice];
                        return VeiculoTile(
                          veiculo: veiculo,
                          aoTocar: () => context.go(
                            AppRoutes.veiculo(clienteId, veiculo.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
