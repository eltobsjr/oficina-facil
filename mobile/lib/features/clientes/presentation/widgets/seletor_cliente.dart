import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/erro/mensagem_de_erro.dart';
import '../../../../core/widgets/campo_de_busca.dart';
import '../../../../core/widgets/estados.dart';
import '../../domain/entities/cliente.dart';
import '../providers/clientes_providers.dart';
import 'cliente_tile.dart';

/// Busca um cliente por nome ou documento e devolve o escolhido em [aoSelecionar].
/// Usado para transferir veículo e, na F5, para abrir OS. Só mostra clientes ativos e deixa de
/// fora [excluirId] (por exemplo, o dono atual).
class SeletorCliente extends ConsumerStatefulWidget {
  const SeletorCliente({super.key, required this.aoSelecionar, this.excluirId});

  final ValueChanged<Cliente> aoSelecionar;
  final String? excluirId;

  @override
  ConsumerState<SeletorCliente> createState() => _SeletorClienteState();
}

class _SeletorClienteState extends ConsumerState<SeletorCliente> {
  var _texto = '';

  @override
  Widget build(BuildContext context) {
    final resultado = ref.watch(clientesBuscaProvider(_texto));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CampoDeBuscaComEspera(
          autofocus: true,
          aoBuscar: (texto) => setState(() => _texto = texto.trim()),
          dica: 'Buscar cliente por nome ou documento',
        ),
        const SizedBox(height: 12),
        Flexible(
          child: SizedBox(
            height: 320,
            child: resultado.when(
              loading: () => const Carregando(),
              error: (erro, _) => EstadoErro(
                mensagem: mensagemDeErro(erro),
                aoTentarDeNovo: () =>
                    ref.invalidate(clientesBuscaProvider(_texto)),
              ),
              data: (pagina) {
                final opcoes = pagina.itens
                    .where((c) => c.ativo && c.id != widget.excluirId)
                    .toList();
                if (opcoes.isEmpty) {
                  return const EstadoVazio(
                    mensagem: 'Nenhum cliente ativo encontrado.',
                    icone: Icons.people_outline,
                  );
                }
                return ListView.separated(
                  itemCount: opcoes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, indice) => ClienteTile(
                    cliente: opcoes[indice],
                    aoTocar: () => widget.aoSelecionar(opcoes[indice]),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
