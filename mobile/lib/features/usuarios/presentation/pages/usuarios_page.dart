import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/erro/mensagem_de_erro.dart';
import '../../../../core/perfil.dart';
import '../../../../core/router/redirecionamento.dart';
import '../../../../core/widgets/estados.dart';
import '../../../../core/widgets/perfil_rotulo.dart';
import '../providers/usuarios_providers.dart';
import '../widgets/usuario_tile.dart';

/// T03: lista de usuários, com busca, filtros por perfil e situação e rolagem infinita.
class UsuariosPage extends ConsumerStatefulWidget {
  const UsuariosPage({super.key});

  @override
  ConsumerState<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends ConsumerState<UsuariosPage> {
  final _rolagem = ScrollController();
  final _busca = TextEditingController();
  Timer? _espera;

  @override
  void initState() {
    super.initState();
    _rolagem.addListener(_aoRolar);
    // Ao voltar para a tela, parte de uma busca limpa.
    _busca.text = ref.read(filtroUsuariosProvider).texto;
  }

  @override
  void dispose() {
    _espera?.cancel();
    _rolagem.dispose();
    _busca.dispose();
    super.dispose();
  }

  void _aoRolar() {
    if (_rolagem.position.extentAfter < 300) {
      ref.read(usuariosListaProvider.notifier).carregarMais();
    }
  }

  void _aoDigitar(String texto) {
    // Espera o usuário parar de digitar para não consultar a cada letra.
    _espera?.cancel();
    _espera = Timer(const Duration(milliseconds: 400), () {
      ref.read(filtroUsuariosProvider.notifier).definirTexto(texto);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtro = ref.watch(filtroUsuariosProvider);
    final lista = ref.watch(usuariosListaProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.usuarioNovo),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Novo usuário'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _busca,
              onChanged: _aoDigitar,
              decoration: const InputDecoration(
                labelText: 'Buscar por nome ou e-mail',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Todos os perfis'),
                  selected: filtro.perfil == null,
                  onSelected: (_) => ref
                      .read(filtroUsuariosProvider.notifier)
                      .definirPerfil(null),
                ),
                for (final perfil in Perfil.values) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(perfil.rotulo),
                    selected: filtro.perfil == perfil,
                    onSelected: (_) => ref
                        .read(filtroUsuariosProvider.notifier)
                        .definirPerfil(perfil),
                  ),
                ],
                const SizedBox(width: 24),
                ChoiceChip(
                  label: const Text('Ativos'),
                  selected: filtro.ativo == true,
                  onSelected: (marcado) => ref
                      .read(filtroUsuariosProvider.notifier)
                      .definirAtivo(marcado ? true : null),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Inativos'),
                  selected: filtro.ativo == false,
                  onSelected: (marcado) => ref
                      .read(filtroUsuariosProvider.notifier)
                      .definirAtivo(marcado ? false : null),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
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
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(usuariosListaProvider.future),
                  child: ListView.builder(
                    controller: _rolagem,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: dados.itens.length + (dados.temMais ? 1 : 0),
                    itemBuilder: (context, indice) {
                      if (indice == dados.itens.length) {
                        return dados.falhouAoCarregarMais
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: TextButton(
                                    onPressed: () => ref
                                        .read(usuariosListaProvider.notifier)
                                        .carregarMais(),
                                    child: const Text('Tentar carregar mais'),
                                  ),
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                      }
                      final usuario = dados.itens[indice];
                      return UsuarioTile(
                        usuario: usuario,
                        aoTocar: () => context.go('/usuarios/${usuario.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
