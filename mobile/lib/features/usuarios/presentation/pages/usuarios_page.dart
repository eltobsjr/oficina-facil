import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/erro/mensagem_de_erro.dart';
import '../../../../core/perfil.dart';
import '../../../../core/router/redirecionamento.dart';
import '../../../../core/widgets/campo_de_busca.dart';
import '../../../../core/widgets/chips.dart';
import '../../../../core/widgets/estados.dart';
import '../../../../core/widgets/largura_maxima.dart';
import '../../../../core/widgets/lista_paginada_view.dart';
import '../../../../core/widgets/perfil_rotulo.dart';
import '../../../../core/widgets/tela_com_sub_barra.dart';
import '../../domain/entities/usuario.dart';
import '../providers/usuarios_providers.dart';
import '../widgets/usuario_tile.dart';

/// T03: lista de usuários, com busca, filtros por perfil e situação e rolagem infinita.
class UsuariosPage extends ConsumerStatefulWidget {
  const UsuariosPage({super.key});

  @override
  ConsumerState<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends ConsumerState<UsuariosPage> {
  @override
  Widget build(BuildContext context) {
    final filtro = ref.watch(filtroUsuariosProvider);
    final lista = ref.watch(usuariosListaProvider);
    final filtros = ref.read(filtroUsuariosProvider.notifier);

    return TelaComSubBarra(
      titulo: 'Usuários',
      rotuloAcao: 'Novo usuário',
      aoAcionar: () => context.go(AppRoutes.usuarioNovo),
      filho: LarguraMaxima(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: CampoDeBuscaComEspera(
                textoInicial: filtro.texto,
                aoBuscar: filtros.definirTexto,
                dica: 'Buscar por nome ou e-mail',
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  ChipDeFiltro(
                    rotulo: 'Todos os perfis',
                    selecionado: filtro.perfil == null,
                    aoSelecionar: (_) => filtros.definirPerfil(null),
                  ),
                  for (final perfil in Perfil.values) ...[
                    const SizedBox(width: 8),
                    ChipDeFiltro(
                      rotulo: perfil.rotulo,
                      selecionado: filtro.perfil == perfil,
                      aoSelecionar: (_) => filtros.definirPerfil(perfil),
                    ),
                  ],
                  const SizedBox(width: 24),
                  ChipDeFiltro(
                    rotulo: 'Ativos',
                    selecionado: filtro.ativo == true,
                    aoSelecionar: (marcado) =>
                        filtros.definirAtivo(marcado ? true : null),
                  ),
                  const SizedBox(width: 8),
                  ChipDeFiltro(
                    rotulo: 'Inativos',
                    selecionado: filtro.ativo == false,
                    aoSelecionar: (marcado) =>
                        filtros.definirAtivo(marcado ? false : null),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: lista.when(
                loading: () => const Carregando(),
                error: (erro, _) => EstadoErro(
                  mensagem: mensagemDeErro(erro),
                  aoTentarDeNovo: () => ref.invalidate(usuariosListaProvider),
                ),
                data: (dados) {
                  if (dados.itens.isEmpty) {
                    return const EstadoVazio(
                      mensagem: 'Nenhum usuário encontrado.',
                      icone: Icons.group_off_outlined,
                    );
                  }
                  return ListaPaginadaView<Usuario>(
                    dados: dados,
                    aoCarregarMais: ref
                        .read(usuariosListaProvider.notifier)
                        .carregarMais,
                    aoAtualizar: () =>
                        ref.refresh(usuariosListaProvider.future),
                    itemBuilder: (context, usuario) => UsuarioTile(
                      usuario: usuario,
                      aoTocar: () => context.go(AppRoutes.usuario(usuario.id)),
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
