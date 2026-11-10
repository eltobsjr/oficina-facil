import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/erro/mensagem_de_erro.dart';
import '../../../../core/router/redirecionamento.dart';
import '../../../../core/widgets/campo_de_busca.dart';
import '../../../../core/widgets/estados.dart';
import '../../../../core/widgets/largura_maxima.dart';
import '../../../../core/widgets/lista_paginada_view.dart';
import '../../../../core/widgets/tela_com_sub_barra.dart';
import '../../domain/entities/cliente.dart';
import '../providers/clientes_providers.dart';
import '../widgets/cliente_tile.dart';

/// T05: lista de clientes, com busca por nome ou documento e rolagem infinita.
class ClientesPage extends ConsumerStatefulWidget {
  const ClientesPage({super.key});

  @override
  ConsumerState<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends ConsumerState<ClientesPage> {
  @override
  Widget build(BuildContext context) {
    final busca = ref.watch(buscaClientesProvider);
    final lista = ref.watch(clientesListaProvider);

    return TelaComSubBarra(
      titulo: 'Clientes',
      rotuloAcao: 'Novo cliente',
      aoAcionar: () => context.go(AppRoutes.clienteNovo),
      filho: LarguraMaxima(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: CampoDeBuscaComEspera(
                textoInicial: ref.read(buscaClientesProvider),
                aoBuscar: ref.read(buscaClientesProvider.notifier).definir,
                dica: 'Buscar por nome ou documento',
              ),
            ),
            Expanded(
              child: lista.when(
                loading: () => const Carregando(),
                error: (erro, _) => EstadoErro(
                  mensagem: mensagemDeErro(erro),
                  aoTentarDeNovo: () => ref.invalidate(clientesListaProvider),
                ),
                data: (dados) {
                  if (dados.itens.isEmpty) {
                    return EstadoVazio(
                      mensagem: busca.trim().isEmpty
                          ? 'Nenhum cliente cadastrado ainda.'
                          : 'Nenhum cliente encontrado para essa busca.',
                      icone: Icons.people_outline,
                    );
                  }
                  return ListaPaginadaView<Cliente>(
                    dados: dados,
                    aoCarregarMais: ref
                        .read(clientesListaProvider.notifier)
                        .carregarMais,
                    aoAtualizar: () =>
                        ref.refresh(clientesListaProvider.future),
                    itemBuilder: (context, cliente) => ClienteTile(
                      cliente: cliente,
                      aoTocar: () => context.go(AppRoutes.cliente(cliente.id)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
